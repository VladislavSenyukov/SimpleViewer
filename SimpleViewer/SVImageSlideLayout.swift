//
//  SVImageSlideLayout.swift
//  SimpleViewer
//
//  Created by ruckef on 17.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import AppKit

class SVImageSlideLayout: NSCollectionViewFlowLayout {
    
    var oldSize = CGSizeZero
    
    override var collectionViewContentSize: NSSize {
        let size = NSSizeToCGSize(super.collectionViewContentSize)
        if !CGSizeEqualToSize(oldSize, CGSizeZero) && !CGSizeEqualToSize(oldSize, size) {
            invalidateLayout()
        }
        oldSize = size
        return NSSizeFromCGSize(size)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: NSRect) -> Bool {
        return true
    }
}