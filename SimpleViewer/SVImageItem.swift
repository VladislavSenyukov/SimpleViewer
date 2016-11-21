//
//  SVImageItem.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

class SVImageItem: NSObject {
    
    private let url: NSURL
    static let imageKey = "imageLoaded"
    var cachedSize = NSZeroSize
    var imageRef: CGImageRef?
    dynamic var imageLoaded = false
    
    init(url: NSURL) {
        self.url = url
        self.cachedSize = url.imageSize()
        super.init()
        loadImageFile()
    }
    
    func fittingSizeForCollectionSize(collectionSize: CGSize, collectionInsets: NSEdgeInsets) -> NSSize {
        let availableHeight = collectionSize.height - collectionInsets.top - collectionInsets.bottom
        let size = cachedSize.fittingSizeForHeight(availableHeight)
        return size
    }
    
    func loadImageFile() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let image = NSImage(contentsOfURL: self.url) {
                let imageRef = image.cgImage
                dispatch_async(dispatch_get_main_queue(), {
                    self.imageRef = imageRef
                    self.imageLoaded = true
                })
            }
        }
    }
}