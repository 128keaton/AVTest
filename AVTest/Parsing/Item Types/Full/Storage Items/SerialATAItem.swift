//
//  SerialATAItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct SerialATAItem: StorageItem {
    var storageItemType: String = "SerialATA"
    var dataType: String = "SPSerialATADataType"

    var deviceSerialNumber: String
    var _size: String?
    var _deviceModel: String?

    var description: String {
        return "\(storageItemType) Drive: \(size) - \(deviceSerialNumber)"
    }

    var size: String {
        if let validSize = _size {
            return validSize
        }
        return String()
    }
    
    var isDiscDrive: Bool{
        return _size == nil
    }

    enum CodingKeys: String, CodingKey {
        case deviceSerialNumber = "device_serial"
        case _size = "size"
        case _deviceModel = "device_model"
    }
}

struct SerialATAControllerItem: ItemType {
    var storageItemType: String = "SerialATA"
    var dataType: String = "SPSerialATADataType"

    var description: String {
        return "\(storageItemType): \(allDrives) \(allDiscDrives)"
    }

    var items: [SerialATAItem]

    var allDrives: [SerialATAItem] {
        return items.filter { $0.size != "" && $0.deviceSerialNumber != "" }
    }

    var allDiscDrives: [SerialATAItem] {
        return items.filter { $0.isDiscDrive }
    }

    var hasDrives: Bool {
        return allDrives.count > 0
    }

    var hasDiscDrive: Bool {
        return allDiscDrives.count > 0
    }

    enum CodingKeys: String, CodingKey {
        case items = "_items"
    }
}
