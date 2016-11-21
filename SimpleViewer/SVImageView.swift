//
//  SVImageView.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

class SVImageView: SVLayeredView {
    
    var cgImage: CGImageRef? {
        didSet {
            layer?.contents = cgImage
        }
    }
}