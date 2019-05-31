//
//  DisplayItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct DisplayItem: ItemType {
    static var isNested: Bool = false
    var dataType: SPDataType = .display

    var graphicsCardModel: String
    var graphicsCardVRAM: String?
    var graphicsCardVRAMShared: String?


    var description: String {
        return "\(graphicsCardModel): \(graphicsCardVRAM ?? graphicsCardVRAMShared ?? "No VRAM")"
    }

    enum CodingKeys: String, CodingKey {
        case graphicsCardModel = "sppci_model"
        case graphicsCardVRAM = "spdisplays_vram"
        case graphicsCardVRAMShared = "spdisplays_vram_shared"
    }
}
