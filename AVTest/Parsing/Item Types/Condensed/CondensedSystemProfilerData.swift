//
//  CondensedSystemProfilerData.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/24/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct CondensedSystemProfilerData: Encodable {
    var model: String?
    var serialNumber: String?
    var processorInfo: String?
    var numberOfProcessors: Int?
    var totalMemory: String?

    var storageDevices: [CondensedStorageItem]? = []
    var discDrives: [CondensedStorageItem]? = []
    var graphicsCards: [CondensedDisplayItem]?

    var batteryHealth: CondensedBatteryHealth?

    enum CodingKeys: String, CodingKey {
        case storageDevices, graphicsCards, discDrives, numberOfProcessors, serialNumber, model
        case batteryHealth = "battery"
        case processorInfo = "processor"
        case totalMemory = "memory"
    }

    init(from systemProfilerData: [SystemProfilerData]) {
        if let hardwareDataItem = systemProfilerData.first(where: { $0.hardwareInformation != nil }) {
            let hardwareInformation = hardwareDataItem.hardwareInformation!

            processorInfo = hardwareInformation.cpuType
            totalMemory = hardwareInformation.physicalMemory
            serialNumber = hardwareInformation.serialNumber
            numberOfProcessors = hardwareInformation.physicalProcessorCount
            model = hardwareInformation.machineModel
        }

        if let batteryHealthDataItem = systemProfilerData.first(where: { $0.batteryHealth != nil }) {
            self.batteryHealth = CondensedBatteryHealth(from: batteryHealthDataItem.batteryHealth!)
        }

        if let displayDataItem = systemProfilerData.first(where: { $0.displayInformation != nil }) {
            self.graphicsCards = displayDataItem.displayInformation!.map { CondensedDisplayItem(from: $0) }
        }

        if let serialATADataItem = systemProfilerData.first(where: { $0.serialATAStorageDevices != nil }) {
            let condensedItems = serialATADataItem.serialATAStorageDevices!.map { CondensedStorageItem(from: $0) }
            self.storageDevices?.append(contentsOf: condensedItems)
        }

        if let discDriveDataItem = systemProfilerData.first(where: { $0.discDrives != nil }) {
            let condensedItems = discDriveDataItem.discDrives!.map { CondensedStorageItem(from: $0) }
            self.discDrives?.append(contentsOf: condensedItems)
        }

        if let NVMeDataItem = systemProfilerData.first(where: { $0.NVMeStorageDevices != nil }) {
            let condensedItems = NVMeDataItem.NVMeStorageDevices!.map { CondensedStorageItem(from: $0) }
            self.storageDevices?.append(contentsOf: condensedItems)
        }
    }
}
