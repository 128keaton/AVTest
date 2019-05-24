//
//  HardwareItem.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

class HardwareItem: ItemType {
    var dataType: String = "SPHardwareDataType"

    var physicalMemory: String
    var machineName: String
    var machineModel: String
    var cpuType: String
    var cpuCores: Int
    var serialNumber: String
    var physicalProcessorCount: Int

    var description: String {
        return "\(machineName): \(machineModel) - \(physicalMemory) - \(physicalProcessorCount)x \(cpuType) - \(cpuCores) Cores - \(serialNumber)"
    }

    required init(from decoder: Decoder)throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.physicalMemory = try container.decode(String.self, forKey: .physicalMemory)
        self.machineName = try container.decode(String.self, forKey: .machineName)
        self.machineModel = try container.decode(String.self, forKey: .machineModel)
        self.cpuType = try container.decode(String.self, forKey: .cpuType)
        self.cpuCores = try container.decode(Int.self, forKey: .cpuCores)
        self.serialNumber = try container.decode(String.self, forKey: .serialNumber)
        self.physicalProcessorCount = try container.decode(Int.self, forKey: .physicalProcessorCount)
        
        SerialNumberMatcher.matchToProductName(self.serialNumber) { (newModel) in
            self.machineModel = newModel
        }
    }

    private func getDetailedCPUInfo() -> String? {
        let launchPath = "/usr/sbin/sysctl"
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return nil
        }

        let infoTask = Process()
        let standardPipe = Pipe()

        infoTask.launchPath = launchPath
        infoTask.arguments = ["-n", "machdep.cpu.brand_string"]
        infoTask.standardOutput = standardPipe
        infoTask.waitUntilExit()

        infoTask.launch()

        let detailedCPUInfoData = standardPipe.fileHandleForReading.readDataToEndOfFile()

        if detailedCPUInfoData.count > 0,
            let detailedCPUInfo = String(data: detailedCPUInfoData, encoding: .utf8) {
            return detailedCPUInfo
        }

        return nil
    }

    func updateCPUInfo(_ newCPUInfo: String) {
        self.cpuType = newCPUInfo
    }

    enum CodingKeys: String, CodingKey {
        case physicalMemory = "physical_memory"
        case machineName = "machine_name"
        case machineModel = "machine_model"
        case cpuType = "cpu_type"
        case cpuCores = "number_processors"
        case serialNumber = "serial_number"
        case physicalProcessorCount = "packages"
    }
}
