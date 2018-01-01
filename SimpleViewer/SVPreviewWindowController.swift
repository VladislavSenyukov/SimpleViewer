//
//  SVWindowController.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

protocol SVCollectionViewUpdatable {
    func updateCollectionViewInsertion(_ indexPaths: Set<IndexPath>)
    func updateCollectionViewRemoval(_ indexPaths: Set<IndexPath>)
}

protocol SVNibNamable {
    static var nibName: String { get }
}

class SVPreviewWindowController: NSWindowController {

    @IBOutlet fileprivate weak var collectionView: SVCollectionView!
    @IBOutlet fileprivate weak var scrollView: NSScrollView!
    
    fileprivate lazy var datasource = SVImageDatasource()
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        datasource.addObserver(self, forKeyPath: datasource.itemsKey, options: .new, context: nil)
        collectionView.register(NSNib(nibNamed: SVImageCollectionCell.nibName, bundle: nil), forItemWithIdentifier: SVImageCollectionCell.nibName)
        collectionView.register(forDraggedTypes: [NSURLPboardType])
//        collectionView.setDraggingSourceOperationMask(.every, forLocal: false)
    }
    
    func appendImageFiles(_ urls: [URL]) {
        datasource.appendImageURLs(urls)
    }
    
    func clearImages() {
        datasource.clear()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // observe handler to insert or remove items in our collection on datasource update
        if keyPath != nil && keyPath! == datasource.itemsKey && change != nil {
            if let changeKindInt = change![NSKeyValueChangeKey.kindKey] as? UInt {
                if let kind = NSKeyValueChange(rawValue: changeKindInt) {
                    if kind == .insertion || kind == .removal {
                        if let indices = change![NSKeyValueChangeKey.indexesKey] as? IndexSet {
                            let indexPathsArray = indices.map({ (idx) -> IndexPath in
                                return IndexPath(item: idx, section: 0)
                            })
                            let indexPaths = Set<IndexPath>(indexPathsArray)
                            switch kind {
                            case .insertion:
                                updateCollectionViewInsertion(indexPaths)
                            case .removal:
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
    func updateCollectionViewInsertion(_ indexPaths: Set<IndexPath>) {
        NSAnimationContext.current().duration = 0.25
        collectionView.animator().insertItems(at: indexPaths)
    }
    
    func updateCollectionViewRemoval(_ indexPaths: Set<IndexPath>) {
        NSAnimationContext.current().duration = 0.25
        collectionView.animator().deleteItems(at: indexPaths)
    }
}

extension SVPreviewWindowController : NSCollectionViewDataSource {
    
    //MARK: Collection Datasource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: SVImageCollectionCell.nibName, for: indexPath) as! SVImageSlideItem
        let imageItem = datasource[indexPath]
        item.representedObject = imageItem
        item.delegate = self
        return item
    }
}

extension SVPreviewWindowController : SVCollectionViewDelegate {
    
    // MARK: Drag&Drop from the outside of the app
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<IndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        return .copy
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDropURLs URLs: [URL], atIndexPath indexPath: IndexPath) {
        datasource.insertImageURLs(URLs, atIndex: indexPath.item)
    }
}

extension SVPreviewWindowController : NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
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
    func imageSlideItemDeleteClicked(_ item: SVImageSlideItem) {
        deleteSelectedImages()
    }
    
    func deleteSelectedImages() {
        let paths = collectionView.selectionIndexPaths
        datasource.removeItems(paths)
    }
}
