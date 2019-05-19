//
//  NestedAudioItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
struct NestedAudioItem: ItemType {
    var dataType: String = "SPAudioDataType"
    var items: [AudioItem]
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "_name"
        case items = "_items"
    }
}

