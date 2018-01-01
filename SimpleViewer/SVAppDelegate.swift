//
//  AppDelegate.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Cocoa

@NSApplicationMain
class SVAppDelegate: NSObject, NSApplicationDelegate {

    lazy var previewWC = SVPreviewWindowController()
    var window: NSWindow? { return previewWC.window }
    var choosing = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        chooseFiles()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            chooseFiles()
        }
        return false
    }
    
    @IBAction func openFiles(_ sender: AnyObject) {
        chooseFiles()
    }

    @IBAction func clearFiles(_ sender: AnyObject) {
        previewWC.clearImages()
    }
    
    func chooseFiles() {
        if !previewWC.window!.isVisible {
            previewWC.showWindow(self)
        }
        if !choosing {
            choosing = true
            SVOpenPanel.chooseFiles({ (urls) in
                self.choosing = false
                self.didSelectFiles(urls)
            })
        }
    }
    
    func didSelectFiles(_ urls: [URL]) {
        previewWC.appendImageFiles(urls)
    }
}
