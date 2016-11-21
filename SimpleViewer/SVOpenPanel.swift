//
//  SVOpenPanel.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

typealias SVChooseFilesCompletion = (urls: [NSURL]) -> ()

class SVOpenPanel {
    static func chooseFiles(completion: SVChooseFilesCompletion) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.allowedFileTypes = [kUTTypeImage as String]
        panel.message = "Choose images or a directory to open"
        panel.prompt = "Choose"
        let desktopDirectory = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true).first!
        panel.directoryURL = NSURL(string: desktopDirectory)
        
        panel.beginWithCompletionHandler {[unowned panel] (succes) in
            if succes == 1 {
                completion(urls: panel.URLs)
            } else {
                completion(urls: [])
            }
        }
    }
}