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

    enum CodingKeys: String, CodingKey {
        case name = "_name"
        case manufacturer = "coreaudio_device_manufacturer"
    }
}
