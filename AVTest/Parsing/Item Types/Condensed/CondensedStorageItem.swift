//
//  CondensedStorageItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/24/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct CondensedStorageItem: Encodable {
    var deviceSerialNumber: String
    var storageItemType: String
    var storageDeviceSize: Double?
    var isDiscDrive: Bool = false

    init(from storageItem: StorageItem) {
        deviceSerialNumber = storageItem.deviceSerialNumber

        print(storageItem._size!.filter("01234567890.".contains))
        if let validSize = storageItem._size,
            let validDoubleSize = Double(validSize.filter("01234567890.".contains)) {
            storageDeviceSize = validDoubleSize.rounded()
        } else {
            isDiscDrive = true
        }

        if storageItem.storageItemType == "SerialATA" {
            storageItemType = "SATA"
        } else {
            storageItemType = "NVMe"
        }
    }

    enum CodingKeys: String, CodingKey {
        case deviceSerialNumber = "serialNumber"
        case storageItemType = "connection"
        case storageDeviceSize = "size"
        case isDiscDrive = "discDrive"
    }
}
