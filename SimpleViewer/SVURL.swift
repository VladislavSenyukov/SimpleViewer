//
//  SVURL.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Foundation

func SVFilterImageUrls(_ urls: [URL]) -> [URL] {
    var allUrls = [URL]()
    var images = [URL]()
    var directories = [URL]()
    for url in urls {
        if url.hasDirectoryPath {
            directories.append(url)
        } else {
            images.append(url)
        }
    }
    allUrls.append(contentsOf: images)
    for directoryURL in directories {
        let imageURLsInDirectory = directoryURL.extractImageURLsFromDirectory()
        allUrls.append(contentsOf: imageURLsInDirectory)
    }
    return allUrls
}

extension URL {
    
    func extractImageURLsFromDirectory() -> [URL] {
        var imageURLs = [URL]()
        let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: [URLResourceKey.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) { (url, error) -> Bool in
            print("Directory enumerator failed at \(url) with error: \(error.localizedDescription)")
            return true
        }!
        for element in enumerator {
            if let url = element as? URL {
                if url.representsImage {
                    imageURLs.append(url)
                }
            }
        }
        return imageURLs
    }
    
    var representsImage: Bool {
        if let resourceValues = try? resourceValues(forKeys: [URLResourceKey.typeIdentifierKey]) {
            if let type = resourceValues.typeIdentifier {
                return UTTypeConformsTo(type as CFString, kUTTypeImage)
            }
        }
        return false
    }
    
    func imageSize() -> NSSize {
        var width = CGFloat(0)
        var height = CGFloat(0)
        if let source = CGImageSourceCreateWithURL(self as CFURL, nil) {
            let options: [String: AnyObject] = [kCGImageSourceShouldCache as String : false as AnyObject]
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, options as CFDictionary?) {
                let dic = properties as NSDictionary
                if let w = dic.value(forKey: kCGImagePropertyPixelWidth as String) as? CGFloat {
                    width = w
                }
                if let h = dic.value(forKey: kCGImagePropertyPixelHeight as String) as? CGFloat {
                    height = h
                }
            }
        }
        return NSSize(width: width, height: height)
    }
}
