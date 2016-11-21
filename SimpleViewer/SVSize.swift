//
//  SVSize.swift
//  SimpleViewer
//
//  Created by ruckef on 20.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Foundation

extension NSSize {
    
    func fittingSizeForHeight(height: CGFloat) -> NSSize {
        let ratio = height / self.height
        let size = NSSize(width: self.width * ratio, height: height)
        return size
    }
}