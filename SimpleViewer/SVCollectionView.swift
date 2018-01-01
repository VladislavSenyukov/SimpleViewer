//
//  SVCollectionView.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

protocol SVCollectionViewDelegate : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didDropURLs URLs: [URL], atIndexPath indexPath: IndexPath)
}

class SVCollectionView: NSCollectionView {
    
    private var dragInsertionIndexPath: IndexPath?
    private var isDragValid = false { // when a dragging session cursor is inside the view and has valid items
        didSet {
            if !isDragValid {
                dragInsertionIndexPath = nil
                needsDisplay = true
            }
        }
    }
    
    private var imageFilterOptions: [String : Any] {
        return [NSPasteboardURLReadingContentsConformToTypesKey : NSImage.imageTypes()]
    }

    private var itemSpacing : CGFloat {
        var spacing = CGFloat(0)
        if let flowLayout = collectionViewLayout as? NSCollectionViewFlowLayout {
            spacing = flowLayout.minimumInteritemSpacing
        }
        return spacing
    }
    
    private var scrollOffset : CGFloat {
        var offset = CGFloat(0)
        if let scrollView = superview?.superview as? NSScrollView {
            offset = scrollView.documentVisibleRect.origin.x
        }
        return offset
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isDragValid = doesPasteboardHaveImages(sender)
        let operation = isDragValid ? .copy : NSDragOperation()
        return operation
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        let indexPath = actualInsertionIndexPathFromPath(sender)
        let dragInsertionChanged = dragInsertionIndexPath == nil || dragInsertionIndexPath!.item != indexPath.item
        if dragInsertionChanged && isDragValid {
            // means that index path of insertion is just updated
            dragInsertionIndexPath = indexPath
            needsDisplay = true
        }
        let operation = isDragValid ? .copy : NSDragOperation()
        return operation
    }

    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragValid = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return doesPasteboardHaveImages(sender)
    }

    override func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        isDragValid = false
        let pasteboard = info.draggingPasteboard()
        let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: imageFilterOptions)
        if let d = delegate as? SVCollectionViewDelegate, let theURLs = urls as? [URL], theURLs.count > 0 {
            let actualIP = actualInsertionIndexPathFromPath(info)
            d.collectionView(self, didDropURLs: theURLs, atIndexPath: actualIP)
            return true
        }
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let context = NSGraphicsContext.current()?.cgContext
        if let color = layer?.backgroundColor {
            NSColor(cgColor: color)?.set()
        }
        
        NSRectFill(dirtyRect)
        if var indexPath = dragInsertionIndexPath {
            func drawSeparator(_ x: CGFloat) {
                    context?.setLineWidth(3)
                    NSColor(red: 150/255, green: 200/255, blue: 55/255, alpha: 1).setStroke()
                    let offset = CGFloat(10)
                    let rect = frame
                    context?.move(to: CGPoint(x: x, y: rect.minY+offset))
                    let mixY = rect.maxY-offset
                    context?.addLine(to: CGPoint(x: x, y: mixY))
                    context?.strokePath()
            }
            
            var x: CGFloat!
            
            if indexPath.item < numberOfItems(inSection: 0) {
                if let item = item(at: indexPath) as? SVImageSlideItem {
                    x = item.view.frame.origin.x - itemSpacing/2
                }
            } else {
                indexPath = IndexPath(item: indexPath.item-1, section: 0)
                if let item = item(at: indexPath) as? SVImageSlideItem {
                    x = item.view.frame.origin.x + item.view.frame.size.width + itemSpacing/2
                }
            }
            
            if x != nil {
                drawSeparator(x)
            }
        }
    }
    
    private func doesPasteboardHaveImages(_ info: NSDraggingInfo) -> Bool {
        let pasteboard = info.draggingPasteboard()
        return pasteboard.canReadObject(forClasses: [NSURL.self], options: imageFilterOptions)
    }

    private func actualInsertionIndexPathFromPath(_ info: NSDraggingInfo) -> IndexPath {
        var indexToInsertItemAt: Int?
        // calculate insertion point, items can be inserted before or after an item on which drop occurs, depending on where the cursor hovered: first half of the item - before; second half of the item - after
        let location = info.draggingLocation()
        let indexPath = indexPathForItem(at: location)
        if let ip = indexPath {
            let visibleIP = indexPathsForVisibleItems()
            if visibleIP.contains(ip) {
                var dropPoint = location
                // we should also consider scroll content offset to make decent calculations
                //TODO: this works incorrectly if scrollOffset > 0
                dropPoint.x += scrollOffset
                if let item = item(at: ip) {
                    let dropPointInItem = convert(dropPoint, to: item.view)
                    let dropX = dropPointInItem.x
                    let halfOfItemWidth = item.view.bounds.size.width / 2
                    if dropX < halfOfItemWidth {
                        indexToInsertItemAt = ip.item
                    } else {
                        indexToInsertItemAt = ip.item + 1
                    }
                }
            }
        } else {
            let itemSpace = itemSpacing
            let possibleRightItemLocation = NSPoint(x: location.x+itemSpace, y: location.y)
            // if there is an item on the right we can select it as target index path otherwise it's the end of collection
            if let possibleRightItemIndexPath = indexPathForItem(at: possibleRightItemLocation) {
                indexToInsertItemAt = possibleRightItemIndexPath.item
            }
        }
        if indexToInsertItemAt == nil {
            indexToInsertItemAt = numberOfItems(inSection: 0)
        }
        return IndexPath(item: indexToInsertItemAt!, section: 0)
    }
}
