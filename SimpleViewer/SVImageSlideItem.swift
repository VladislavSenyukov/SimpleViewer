//
//  SVImageSlideItem.swift
//  SimpleViewer
//
//  Created by ruckef on 17.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

protocol SVImageSlideItemDelegate: class {
    func imageSlideItemDeleteClicked(item: SVImageSlideItem)
}

class SVImageSlideItem: NSCollectionViewItem {

    @IBOutlet private weak var cellView: SVImageCollectionCell!
    private var item: SVImageItem? { return representedObject as? SVImageItem}
    private var observing = false
    weak var delegate: SVImageSlideItemDelegate?
    
    override var selected: Bool {
        didSet {
            if selected {
                if let firstResponder = collectionView.window?.firstResponder {
                    if !(firstResponder is SVImageSlideItem) {
                        // any item can become first responder to handle keyboard events
                        collectionView.window?.makeFirstResponder(self)
                    }
                }
            }
            super.selected = selected
            cellView.selected = selected
        }
    }
    
    func addImageItemObserver() {
        if !observing {
            item?.addObserver(self, forKeyPath: SVImageItem.imageKey, options: .New, context: nil)
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
    
    override var representedObject: AnyObject? {
        willSet {
            removeImageItemObserver()
        }
        didSet {
            if let item = representedObject as? SVImageItem {
                cellView.selected = selected
                if let imageRef = item.imageRef {
                    cellView.picture.cgImage = imageRef
                } else {
                    addImageItemObserver()
                }
            }
        }
    }
    
    @IBAction func deleteClicked(sender: AnyObject) {
        delegate?.imageSlideItemDeleteClicked(self)
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyUp(theEvent: NSEvent) {
        if theEvent.keyCode == 51 {
            delegate?.imageSlideItemDeleteClicked(self)
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        // to suppress the beep sound
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == SVImageItem.imageKey {
            if let i = item {
                if i.imageLoaded {
                    cellView.picture.cgImage = i.imageRef
                }
            }
        }
    }
}