//
//  SVImageCollectionCell.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

enum SVImageCollectionCellInsertionSide {
    case Right
    case Left
}

class SVImageCollectionCell: SVColoredView, SVNibNamable {

    @IBOutlet weak var picture: SVImageView!
    @IBOutlet weak var dimOverlayView: SVColoredView!
    @IBOutlet weak var deleteButton: NSButton!
    
    class var nibName: String { return "SVImageCollectionCell" }
    
    var selected = false {
        didSet {
            selected ? showBorder() : hideBorder()
        }
    }
    
    private var leftC: NSLayoutConstraint!
    private var rightC: NSLayoutConstraint!
    private var insertionSide = SVImageCollectionCellInsertionSide.Left
    
    override func initialize() {
        super.initialize()
        translatesAutoresizingMaskIntoConstraints = false
        color = NSColor.randomColor()
        let borderColor = NSColor(red: 150/255, green: 200/255, blue: 55/255, alpha: 1)
        layer?.borderColor = borderColor.CGColor
        dimOverlayView.color = .blackColor()
        dimOverlayView.alphaValue = 0.2
    }
    
    func showBorder() {
        layer?.borderWidth = 4
        dimOverlayView.hidden = false
        deleteButton.hidden = false

    }
    
    func hideBorder() {
        layer?.borderWidth = 0
        dimOverlayView.hidden = true
        deleteButton.hidden = true
    }
}