//
//  AudioItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct AudioItem: ItemType {
    var dataType: String = "SPAudioDataType"

    var name: String
    var manufacturer: String

    var description: String {
        return "\(name): \(manufacturer)"
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "_name"
        case manufacturer = "coreaudio_device_manufacturer"
    }
}

struct NestedAudioItem: ItemType {
    var dataType: String = "SPAudioDataType"
    var items: [AudioItem]
    var name: String
    
    var description: String {
        return "\(name): \(items)"
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "_name"
        case items = "_items"
    }
}


