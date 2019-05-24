//
//  DiscBurningItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct DiscBurningItem: StorageItem {
    var storageItemType: String = "DiscBurning"
    var dataType: String = "DPDiscBurningDataType"
    
    var deviceSerialNumber: String
    var deviceModel: String

    var _size: String? = nil
    
    var description: String {
        return "\(storageItemType): \(deviceSerialNumber)"
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceSerialNumber = "device_serial"
        case deviceModel = "device_model"
    }
}
