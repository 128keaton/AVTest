//
//  HardwareItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct HardwareItem: ItemType {
    var dataType: String = "SPHardwareDataType"
    
    var physicalMemory: String
    var machineName: String
    var machineModel: String
    var cpuType: String
    var cpuCores: Int
    var serialNumber: String

    enum CodingKeys: String, CodingKey {
        case physicalMemory = "physical_memory"
        case machineName = "machine_name"
        case machineModel = "machine_model"
        case cpuType = "cpu_type"
        case cpuCores = "number_processors"
        case serialNumber = "serial_number"
    }
}
