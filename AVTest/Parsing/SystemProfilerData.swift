//
//  SystemProfilerData.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct SystemProfilerData: Codable, CustomStringConvertible {
    var dataType: String
    var items: [Any]?

    var hardwareInformation: HardwareItem? {
        return self.items?.first { type(of: $0) == HardwareItem.self } as? HardwareItem
    }

    var displayInformation: [DisplayItem]? {
        return self.items as? [DisplayItem]
    }

    var batteryHealth: BatteryHealthInfo? {
        if let powerItem = self.items?.first(where: { type(of: $0) == PowerItem.self }) as? PowerItem,
            let batteryItem = powerItem.battery,
            let healthInfo = batteryItem.healthInfo {
            return healthInfo
        }

        return nil
    }

    var NVMeStorageDevices: [NVMeItem]? {
        return self.items as? [NVMeItem]
    }

    var serialATAStorageDevices: [SerialATAItem]? {
        if let storageItems = self.items as? [SerialATAControllerItem],
            (storageItems.filter { $0.hasDrives }).count > 0 {
            return storageItems.flatMap { $0.items }.filter { !$0.isDiscDrive }
        }
        return nil
    }

    var discDrives: [SerialATAItem]? {
        if let storageItems = self.items as? [SerialATAControllerItem] {
            return storageItems.flatMap { $0.items }.filter { $0.isDiscDrive }
        }
        return nil
    }

    var description: String {
        var descriptionString = dataType

        if let items = items as? [DisplayItem] {
            descriptionString = "Display Items: \(items)"
        }

        if let items = items as? [HardwareItem] {
            descriptionString = "Hardware Items: \(items)"
        }

        if let items = items as? [NestedMemoryItem] {
            descriptionString = "Memory Items: \(items)"
        }

        if let items = items as? [NestedAudioItem] {
            descriptionString = "Audio Items: \(items)"
        }

        if let items = items as? [PowerItem] {
            descriptionString = "Power Items: \(items)"
        }

        if let items = items as? [SerialATAControllerItem] {
            if items.filter({ $0.hasDrives }).count > 0 {
                descriptionString = "SATA Drives: \(items.filter({ $0.hasDrives }))"
            }

            if items.filter({ $0.hasDiscDrive }).count > 0 {
                descriptionString += "SATA Disc Drives: \(items.filter({ $0.hasDiscDrive }))"
            }
        }

        return descriptionString
    }

    enum CodingKeys: String, CodingKey {
        case dataType = "_dataType"
        case parentDataType = "_parentDataType"
        case items = "_items"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dataType = try container.decode(String.self, forKey: .dataType)

        if let decode = SystemProfilerData.decoders[dataType] {
            do {
                items = try decode(container) as? [Any]
            } catch {
                print(error)
            }
        } else {
            items = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(dataType, forKey: .dataType)

        if let items = self.items {
            guard let encode = SystemProfilerData.encoders[dataType] else {
                let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid data type: \(dataType).")
                throw EncodingError.invalidValue(self, context)
            }

            try encode(items, &container)
        } else {
            try container.encodeNil(forKey: .items)
        }
    }

    private typealias SystemProfilerDataDecoder = (KeyedDecodingContainer<CodingKeys>) throws -> Any
    private typealias SystemProfilerDataEncoder = (Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void

    private static var decoders: [String: SystemProfilerDataDecoder] = [:]
    private static var encoders: [String: SystemProfilerDataEncoder] = [:]

    static func register<A: Codable>(_ type: A.Type, for typeName: String) {
        decoders[typeName] = { container in
            try container.decode([A].self, forKey: .items)
        }

        encoders[typeName] = { items, container in
            try container.encode(items as! [A], forKey: .items)
        }
    }
}

