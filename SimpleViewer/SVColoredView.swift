//
//  SVImageSlideView.swift
//  SimpleViewer
//
//  Created by ruckef on 17.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import AppKit

class SVColoredView: SVLayeredView {
    
    @IBInspectable var color: NSColor? {
        didSet {
            layer?.backgroundColor = color?.CGColor
        }
    }
}