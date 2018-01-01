//
//  SVImageItem.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

class SVImageItem: NSObject {
    
    fileprivate let url: URL
    static let imageKey = "imageLoaded"
    var cachedSize = NSZeroSize
    var imageRef: CGImage?
    dynamic var imageLoaded = false
    
    init(url: URL) {
        self.url = url
        self.cachedSize = url.imageSize()
        super.init()
        loadImageFile()
    }
    
    func fittingSizeForCollectionSize(_ collectionSize: CGSize, collectionInsets: EdgeInsets) -> NSSize {
        let availableHeight = collectionSize.height - collectionInsets.top - collectionInsets.bottom
        let size = cachedSize.fittingSizeForHeight(availableHeight)
        return size
    }
    
    func loadImageFile() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if let image = NSImage(contentsOf: self.url) {
                let imageRef = image.cgImage
                DispatchQueue.main.async(execute: {
                    self.imageRef = imageRef
                    self.imageLoaded = true
                })
            }
        }
    }
}
