//
//  SVWindowController.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

protocol SVCollectionViewUpdatable {
    func updateCollectionViewInsertion(indexPaths: Set<NSIndexPath>)
    func updateCollectionViewRemoval(indexPaths: Set<NSIndexPath>)
}

protocol SVNibNamable {
    static var nibName: String { get }
}

class SVPreviewWindowController: NSWindowController {

    @IBOutlet private weak var collectionView: SVCollectionView!
    @IBOutlet private weak var scrollView: NSScrollView!
    
    private lazy var datasource = SVImageDatasource()
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        datasource.addObserver(self, forKeyPath: datasource.itemsKey, options: .New, context: nil)
        collectionView.registerNib(NSNib(nibNamed: SVImageCollectionCell.nibName, bundle: nil), forItemWithIdentifier: SVImageCollectionCell.nibName)
        collectionView.registerForDraggedTypes([NSFilenamesPboardType])
        collectionView.setDraggingSourceOperationMask(.Every, forLocal: false)
    }
    
    func appendImageFiles(urls: [NSURL]) {
        datasource.appendImageURLs(urls)
    }
    
    func clearImages() {
        datasource.clear()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // observe handler to insert or remove items in our collection on datasource update
        if keyPath != nil && keyPath! == datasource.itemsKey && change != nil {
            if let changeKindInt = change![NSKeyValueChangeKindKey] as? UInt {
                if let kind = NSKeyValueChange(rawValue: changeKindInt) {
                    if kind == .Insertion || kind == .Removal {
                        if let indices = change![NSKeyValueChangeIndexesKey] as? NSIndexSet {
                            let indexPathsArray = indices.map({ (idx) -> NSIndexPath in
                                return NSIndexPath(forItem: idx, inSection: 0)
                            })
                            let indexPaths = Set<NSIndexPath>(indexPathsArray)
                            switch kind {
                            case .Insertion:
                                updateCollectionViewInsertion(indexPaths)
                            case .Removal:
                                updateCollectionViewRemoval(indexPaths)
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}

extension SVPreviewWindowController : SVCollectionViewUpdatable {
    func updateCollectionViewInsertion(indexPaths: Set<NSIndexPath>) {
        NSAnimationContext.currentContext().duration = 0.25
        collectionView.animator().insertItemsAtIndexPaths(indexPaths)
    }
    
    func updateCollectionViewRemoval(indexPaths: Set<NSIndexPath>) {
        NSAnimationContext.currentContext().duration = 0.25
        collectionView.animator().deleteItemsAtIndexPaths(indexPaths)
    }
}

extension SVPreviewWindowController : NSCollectionViewDataSource {
    
    //MARK: Collection Datasource
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier(SVImageCollectionCell.nibName, forIndexPath: indexPath) as! SVImageSlideItem
        let imageItem = datasource[indexPath]
        item.representedObject = imageItem
        item.delegate = self
        return item
    }
}

extension SVPreviewWindowController : SVCollectionViewDelegate {
    
    // MARK: Drag&Drop from the outside of the app
    
    func collectionView(collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath?>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return .Copy
    }
    
    func collectionView(collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: NSIndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        return true
    }
    
    func collectionView(collectionView: NSCollectionView, didDropURLs URLs: [NSURL], atIndexPath indexPath: NSIndexPath) {
        datasource.insertImageURLs(URLs, atIndex: indexPath.item)
    }
}

extension SVPreviewWindowController : NSCollectionViewDelegateFlowLayout {
    func collectionView(collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> NSSize {
        let item = datasource[indexPath]
        var sectionInsets = NSEdgeInsetsZero
        if let flowLayout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
            sectionInsets = flowLayout.sectionInset
        }
        let fitImageSize = item.fittingSizeForCollectionSize(collectionView.bounds.size, collectionInsets: sectionInsets)
        return fitImageSize
    }
}

extension SVPreviewWindowController : SVImageSlideItemDelegate {
    func imageSlideItemDeleteClicked(item: SVImageSlideItem) {
        deleteSelectedImages()
    }
    
    func deleteSelectedImages() {
        let paths = collectionView.selectionIndexPaths
        datasource.removeItems(paths)
    }
}