//
//  SVOpenPanel.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

typealias SVChooseFilesCompletion = (_ urls: [URL]) -> ()

class SVOpenPanel {
    static func chooseFiles(_ completion: @escaping SVChooseFilesCompletion) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = [kUTTypeImage as String]
        panel.message = "Choose images or a directory to open"
        panel.prompt = "Choose"
        let desktopDirectory = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
        panel.directoryURL = URL(string: desktopDirectory)
        
        panel.begin {[unowned panel] (succes) in
            if succes == 1 {
                completion(panel.urls)
            } else {
                completion([])
            }
        }
    }
}
