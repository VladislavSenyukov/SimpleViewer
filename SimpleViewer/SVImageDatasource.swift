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
    
    private dynamic var items = NSMutableArray()
    private var _items: NSMutableArray { return mutableArrayValueForKey(itemsKey) }
    
    var count: Int { return items.count }
    
    subscript(idxPath: NSIndexPath) -> SVImageItem {
        return items[idxPath.item] as! SVImageItem
    }
    
    func appendImageURLs(urls: [NSURL]) {
        let imageURLs = SVFilterImageUrls(urls)
        let newItems = imageURLs.map{SVImageItem(url: $0)}
        let items = _items
        for imageItem in newItems {
            items.insertObject(imageItem, atIndex: items.count)
        }
    }
    
    func insertImageURLs(urls: [NSURL], atIndex idx: Int) {
        let imageURLs = SVFilterImageUrls(urls)
        let newItems = imageURLs.map{SVImageItem(url: $0)}
        let items = _items
        for imageItem in newItems.reverse() {
            items.insertObject(imageItem, atIndex: idx)
        }
    }
    
    func clear() {
        _items.removeAllObjects()
    }
    
    func removeItems(indexPaths: Set<NSIndexPath>) {
        let set = NSMutableIndexSet()
        for path in indexPaths {
            set.addIndex(path.item)
        }
        _items.removeObjectsAtIndexes(set)
    }
}