//
//  DisplayItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct DisplayItem: Codable {
    var dataType: String = "SPDisplaysDataType"

    var graphicsCardModel: String
    var graphicsCardVRAM: String?
    var graphicsCardVRAMShared: String?

    enum CodingKeys: String, CodingKey {
        case graphicsCardModel = "sppci_model"
        case graphicsCardVRAM = "spdisplays_vram"
        case graphicsCardVRAMShared = "spdisplays_vram_shared"
    }
}

struct DisplayItems: Codable {
    var items: [DisplayItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "_items"
    }
}
