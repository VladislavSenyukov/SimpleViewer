//
//  SVImageSlideLayout.swift
//  SimpleViewer
//
//  Created by ruckef on 17.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import AppKit

class SVImageSlideLayout: NSCollectionViewFlowLayout {
    
    var oldSize = CGSize.zero
    
    override var collectionViewContentSize: NSSize {
        let size = NSSizeToCGSize(super.collectionViewContentSize)
        if !oldSize.equalTo(CGSize.zero) && !oldSize.equalTo(size) {
            invalidateLayout()
        }
        oldSize = size
        return NSSizeFromCGSize(size)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
}
