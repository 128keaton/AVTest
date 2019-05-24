//
//  NVMeItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
struct NVMeItem: StorageItem {
    var storageItemType: String = "NVMe"
    var dataType: String = "SPNVMeDataType"
    
    var deviceSerialNumber: String
    var _size: String?
    
    
    var description: String{
        return "\(storageItemType): \(size) - \(deviceSerialNumber)"
    }
    
    var size: String {
        if let validSize = _size{
            return validSize
        }
        return String()
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceSerialNumber = "device_serial"
        case _size = "size"
    }
}
