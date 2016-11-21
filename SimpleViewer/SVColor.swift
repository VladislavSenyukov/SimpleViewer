//
//  SVColor.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import AppKit

extension NSColor {
    static func randomColor() -> NSColor {
        let divider = 256
        var components = [CGFloat]()
        for _ in 1...3 {
            let component = CGFloat(Int(arc4random()) % divider)
            components.append(component)
        }
        let randomColor = NSColor(red: components[0]/CGFloat(divider-1), green: components[1]/CGFloat(divider-1), blue: components[2]/CGFloat(divider-1), alpha: 1)
        return randomColor
    }
}