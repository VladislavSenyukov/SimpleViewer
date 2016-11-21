//
//  SVCollectionView.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

protocol SVCollectionViewDelegate : NSCollectionViewDelegate {
    func collectionView(collectionView: NSCollectionView, didDropURLs URLs: [NSURL], atIndexPath indexPath: NSIndexPath)
}

class SVCollectionView: NSCollectionView {
    
    private var dragInsertionIndexPath: NSIndexPath?
    private var draggingCursorIsInWindow = false {
        didSet {
            if !draggingCursorIsInWindow {
                dragInsertionIndexPath = nil
                needsDisplay = true
            }
        }
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
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        draggingCursorIsInWindow = true
        return super.draggingEntered(sender)
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        draggingCursorIsInWindow = false
        super.draggingEnded(sender)
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        let indexPath = actualInsertionIndexPathFromPath(sender)
        if dragInsertionIndexPath == nil || dragInsertionIndexPath!.item != indexPath.item {
            // means that index path of insertion is just updated
            dragInsertionIndexPath = indexPath
            needsDisplay = true
        }
        return super.draggingUpdated(sender)
    }
    
    override func draggingEnded(sender: NSDraggingInfo?) {
        super.draggingEnded(sender)
        if let info = sender where draggingCursorIsInWindow {
            let actualIP = actualInsertionIndexPathFromPath(info)
            if shouldBeginDrop(info, atIndexPath: actualIP) {
                if let d = delegate as? SVCollectionViewDelegate {
                    let urls = gatherDroppedURLs(sender)
                    d.collectionView(self, didDropURLs: urls, atIndexPath: actualIP)
                }
            }
        }
        draggingCursorIsInWindow = false
    }
    
    override func drawRect(dirtyRect: NSRect) {
        let context = NSGraphicsContext.currentContext()?.CGContext
        NSColor(CGColor: layer!.backgroundColor!)?.set()
        NSRectFill(dirtyRect)
        if var indexPath = dragInsertionIndexPath {
            func drawSeparator(x: CGFloat) {
                    CGContextSetLineWidth(context, 3)
                    NSColor(red: 150/255, green: 200/255, blue: 55/255, alpha: 1).setStroke()
                    let offset = CGFloat(10)
                    CGContextMoveToPoint(context, x, dirtyRect.minY+offset)
                    let mixY = dirtyRect.maxY-offset
                    CGContextAddLineToPoint(context, x, mixY)
                    CGContextStrokePath(context)
            }
            
            var x: CGFloat!
            
            if indexPath.item < numberOfItemsInSection(0) {
                if let item = itemAtIndexPath(indexPath) as? SVImageSlideItem {
                    x = item.view.frame.origin.x - itemSpacing/2
                }
            } else {
                indexPath = NSIndexPath(forItem: indexPath.item-1, inSection: 0)
                if let item = itemAtIndexPath(indexPath) as? SVImageSlideItem {
                    x = item.view.frame.origin.x + item.view.frame.size.width + itemSpacing/2
                }
            }
            
            if x != nil {
                drawSeparator(x)
            }
        }
    }
    
    private func shouldBeginDrop(info: NSDraggingInfo, atIndexPath indexPath: NSIndexPath) -> Bool {
        let dropOperation: NSCollectionViewDropOperation = indexPathForItemAtPoint(info.draggingLocation()) != nil ? .On : .Before
        if let shouldBegin = delegate?.collectionView?(self, acceptDrop: info, indexPath: indexPath, dropOperation: dropOperation) {
            return shouldBegin
        }
        return false
    }
    
    private func gatherDroppedURLs(draggingInfo: NSDraggingInfo?) -> [NSURL] {
        // gather all dropped urls
        var droppedURLs = [NSURL]()
        draggingInfo?.enumerateDraggingItemsWithOptions(.Concurrent, forView: self, classes: [NSURL.self], searchOptions: [NSPasteboardURLReadingFileURLsOnlyKey : true]) { (item, idx, stop) in
            if let url = item.item as? NSURL {
                droppedURLs.append(url)
            }
        }
        return droppedURLs
    }
    
    private func actualInsertionIndexPathFromPath(info: NSDraggingInfo) -> NSIndexPath {
        var indexToInsertItemAt: Int?
        // calculate insertion point, items can be inserted before or after an item on which drop occurs, depending on where the cursor hovered: first half of the item - before; second half of the item - after
        let location = info.draggingLocation()
        let indexPath = indexPathForItemAtPoint(location)
        if let ip = indexPath {
            let visibleIP = indexPathsForVisibleItems()
            if visibleIP.contains(ip) {
                var dropPoint = location
                // we should also consider scroll content offset to make decent calculations
                //TODO: this works incorrectly if scrollOffset > 0
                dropPoint.x += scrollOffset
                if let item = itemAtIndexPath(ip) {
                    let dropPointInItem = convertPoint(dropPoint, toView: item.view)
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
            if let possibleRightItemIndexPath = indexPathForItemAtPoint(possibleRightItemLocation) {
                indexToInsertItemAt = possibleRightItemIndexPath.item
            }
        }
        if indexToInsertItemAt == nil {
            indexToInsertItemAt = numberOfItemsInSection(0)
        }
        return NSIndexPath(forItem: indexToInsertItemAt!, inSection: 0)
    }
}