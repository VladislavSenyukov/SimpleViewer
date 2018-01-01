//
//  SVImage.swift
//  SimpleViewer
//
//  Created by ruckef on 18.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import AppKit

extension NSImage {
    var cgImage: CGImage {
        let imageData = tiffRepresentation!
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let maskRef = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        return maskRef
    }
}
