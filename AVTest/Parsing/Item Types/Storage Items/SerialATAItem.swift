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

    var size: String {
        if let validSize = _size {
            return validSize
        }
        return String()
    }

    enum CodingKeys: String, CodingKey {
        case deviceSerialNumber = "device_serial"
        case _size = "size"
    }
}
