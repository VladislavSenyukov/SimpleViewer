//
//  SVURL.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Foundation

func SVFilterImageUrls(_ urls: [URL]) -> [URL] {
    var images = [URL]()
    let limit = 100
    enumerateURLsRecursively(urls) { (_ url: URL, _ stop: inout Bool) in
        if (images.count >= limit) {
            stop = true
        } else if url.representsImage {
            images.append(url)
        }
    }
    return images
}

func SVFindImageURL(_ urls: [URL]) -> Bool {
    var imageFound = false
    enumerateURLsRecursively(urls) { (_ url: URL, _ stop: inout Bool) in
        if url.representsImage {
            stop = true
            imageFound = true
        }
    }
    return imageFound
}

fileprivate func enumerateURLsRecursively(_ urls: [URL], enumeratorBlock: (_ url: URL, _ stop: inout Bool) -> ()) {
    var stop = false
    for url in urls {
        if (stop) {
            return
        }
        if url.hasDirectoryPath {
            if let urlsInDirectory = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [URLResourceKey.isRegularFileKey, URLResourceKey.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                enumerateURLsRecursively(urlsInDirectory) { (_ url: URL, _ stop: inout Bool) in
                    enumeratorBlock(url, &stop)
                }
            }
        } else {
            enumeratorBlock(url, &stop)
        }
    }
}

extension URL {
    
    func extractImageURLsFromDirectory() -> [URL] {
        var imageURLs = [URL]()
        let enumerator = FileManager.default.enumerator(at: self, includingPropertiesForKeys: [URLResourceKey.isRegularFileKey, URLResourceKey.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) { (url, error) -> Bool in
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
                if let orientation = dic.value(forKey: kCGImagePropertyOrientation as String) as? Int {
                    if orientation > 4 { // need to swap dimensions
                        let tempHeight = height
                        height = width
                        width = tempHeight
                    }
                }
            }
        }
        return NSSize(width: width, height: height)
    }
}
