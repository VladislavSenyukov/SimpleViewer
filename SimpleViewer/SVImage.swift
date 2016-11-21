//
//  SVImage.swift
//  SimpleViewer
//
//  Created by ruckef on 18.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import AppKit

extension NSImage {
    var cgImage: CGImageRef {
        let imageData = TIFFRepresentation!
        let source = CGImageSourceCreateWithData(imageData, nil)!
        let maskRef = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        return maskRef
    }
}