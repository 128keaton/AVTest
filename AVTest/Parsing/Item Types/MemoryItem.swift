//
//  MemoryItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct MemoryItem: Codable {
    var dataType: String = "SPMemoryDataType"
    
    var size: String
    var speed: String
    var status: String
    var type: String

    enum CodingKeys: String, CodingKey {
        case size = "dimm_size"
        case speed = "dimm_speed"
        case status = "dimm_status"
        case type = "dimm_type"
    }
}
