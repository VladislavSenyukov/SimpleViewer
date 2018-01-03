//
//  SVImageDatasource.swift
//  SimpleViewer
//
//  Created by ruckef on 16.11.16.
//  Copyright © 2016 ruckef. All rights reserved.
//

import Foundation

class SVImageDatasource: NSObject {

    let itemsKey = "items"
    
    @objc fileprivate dynamic var items = NSMutableArray()
    fileprivate var _items: NSMutableArray { return mutableArrayValue(forKey: itemsKey) }
    
    var count: Int { return items.count }
    
    subscript(idxPath: IndexPath) -> SVImageItem {
        return items[idxPath.item] as! SVImageItem
    }
    
    func appendImageURLs(_ urls: [URL]) {
        let imageURLs = SVFilterImageUrls(urls)
        let newItems = imageURLs.map{SVImageItem(url: $0)}
        let items = _items
        for imageItem in newItems {
            items.insert(imageItem, at: items.count)
        }
    }
    
    func insertImageURLs(_ urls: [URL], atIndex idx: Int) {
        let imageURLs = SVFilterImageUrls(urls)
        let newItems = imageURLs.map{SVImageItem(url: $0)}
        let items = _items
        for imageItem in newItems.reversed() {
            items.insert(imageItem, at: idx)
        }
    }
    
    func clear() {
        _items.removeAllObjects()
    }
    
    func removeItems(_ indexPaths: Set<IndexPath>) {
        let set = NSMutableIndexSet()
        for path in indexPaths {
            set.add(path.item)
        }
        _items.removeObjects(at: set as IndexSet)
    }
}
