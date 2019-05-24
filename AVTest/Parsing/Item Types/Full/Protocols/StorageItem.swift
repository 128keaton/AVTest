//
//  StorageItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

protocol StorageItem: ItemType {
    var deviceSerialNumber: String { get }
    var storageItemType: String { get }
    var _size: String? { get }

}
