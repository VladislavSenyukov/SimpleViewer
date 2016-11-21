//
//  SVURL.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Foundation

func SVFilterImageUrls(urls: [NSURL]) -> [NSURL] {
    var allUrls = [NSURL]()
    var images = [NSURL]()
    var directories = [NSURL]()
    for url in urls {
        if url.hasDirectoryPath {
            directories.append(url)
        } else {
            images.append(url)
        }
    }
    allUrls.appendContentsOf(images)
    for directoryURL in directories {
        let imageURLsInDirectory = directoryURL.extractImageURLsFromDirectory()
        allUrls.appendContentsOf(imageURLsInDirectory)
    }
    return allUrls
}

extension NSURL {
    
    func extractImageURLsFromDirectory() -> [NSURL] {
        var imageURLs = [NSURL]()
        let enumerator = NSFileManager.defaultManager().enumeratorAtURL(self, includingPropertiesForKeys: [NSURLIsRegularFileKey], options: [.SkipsHiddenFiles, .SkipsPackageDescendants]) { (url, error) -> Bool in
            print("Directory enumerator failed at \(url) with error: \(error.localizedDescription)")
            return true
        }!
        for element in enumerator {
            if let url = element as? NSURL {
                if url.representsImage {
                    imageURLs.append(url)
                }
            }
        }
        return imageURLs
    }
    
    var representsImage: Bool {
        if let resourceValues = try? resourceValuesForKeys([NSURLTypeIdentifierKey]) {
            if let type = resourceValues[NSURLTypeIdentifierKey] as? String {
                return UTTypeConformsTo(type, kUTTypeImage)
            }
        }
        return false
    }
    
    func imageSize() -> NSSize {
        var width = CGFloat(0)
        var height = CGFloat(0)
        if let source = CGImageSourceCreateWithURL(self, nil) {
            let options: [String: AnyObject] = [kCGImageSourceShouldCache as String : false]
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, options) {
                let dic = properties as NSDictionary
                if let w = dic.valueForKey(kCGImagePropertyPixelWidth as String) as? CGFloat {
                    width = w
                }
                if let h = dic.valueForKey(kCGImagePropertyPixelHeight as String) as? CGFloat {
                    height = h
                }
            }
        }
        return NSSize(width: width, height: height)
    }
}