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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        chooseFiles()
    }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            chooseFiles()
        }
        return false
    }
    
    @IBAction func openFiles(sender: AnyObject) {
        chooseFiles()
    }

    @IBAction func clearFiles(sender: AnyObject) {
        previewWC.clearImages()
    }
    
    func chooseFiles() {
        if !previewWC.window!.visible {
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
    
    func didSelectFiles(urls: [NSURL]) {
        previewWC.appendImageFiles(urls)
    }
}