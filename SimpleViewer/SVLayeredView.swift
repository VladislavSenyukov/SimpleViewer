//
//  SVLayeredView.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

class SVLayeredView: SVView {

    override func initialize() {
        super.initialize()
        wantsLayer = true
    }
}