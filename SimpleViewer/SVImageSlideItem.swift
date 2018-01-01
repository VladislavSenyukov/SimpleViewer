//
//  SVImageSlideItem.swift
//  SimpleViewer
//
//  Created by ruckef on 17.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

protocol SVImageSlideItemDelegate: class {
    func imageSlideItemDeleteClicked(_ item: SVImageSlideItem)
}

class SVImageSlideItem: NSCollectionViewItem {

    @IBOutlet fileprivate weak var cellView: SVImageCollectionCell!
    fileprivate var item: SVImageItem? { return representedObject as? SVImageItem}
    fileprivate var observing = false
    weak var delegate: SVImageSlideItemDelegate?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                if let firstResponder = collectionView.window?.firstResponder {
                    if !(firstResponder is SVImageSlideItem) {
                        // any item can become first responder to handle keyboard events
                        collectionView.window?.makeFirstResponder(self)
                    }
                }
            }
            super.isSelected = isSelected
            cellView.selected = isSelected
        }
    }
    
    func addImageItemObserver() {
        if !observing {
            item?.addObserver(self, forKeyPath: SVImageItem.imageKey, options: .new, context: nil)
            observing = !observing
        }
    }
    
    func removeImageItemObserver() {
        if observing {
            item?.removeObserver(self, forKeyPath: SVImageItem.imageKey)
            observing = !observing
        }
    }
    
    deinit {
        removeImageItemObserver()
    }
    
    override func prepareForReuse() {
        removeImageItemObserver()
        super.prepareForReuse()
    }
    
    override var representedObject: Any? {
        willSet {
            removeImageItemObserver()
        }
        didSet {
            if let item = representedObject as? SVImageItem {
                cellView.selected = isSelected
                if let imageRef = item.imageRef {
                    cellView.picture.cgImage = imageRef
                } else {
                    addImageItemObserver()
                }
            }
        }
    }
    
    @IBAction func deleteClicked(_ sender: AnyObject) {
        delegate?.imageSlideItemDeleteClicked(self)
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyUp(with theEvent: NSEvent) {
        if theEvent.keyCode == 51 {
            delegate?.imageSlideItemDeleteClicked(self)
        }
    }
    
    override func keyDown(with theEvent: NSEvent) {
        // to suppress the beep sound
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == SVImageItem.imageKey {
            if let i = item {
                if i.imageLoaded {
                    cellView.picture.cgImage = i.imageRef
                }
            }
        }
    }
}
