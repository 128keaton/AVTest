//
//  SystemProfiler.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa

class SystemProfiler {
    private static var propertyListData: Data = Data()
    private static var detailedCPUInfoData: Data = Data()
    private static var hasParsed: Bool = false

    public static var delegate: SystemProfilerDelegate? = nil
    public static var audioItems: [AudioItem] = []
    public static var discBurningItems: [DiscBurningItem] = []
    public static var displayItems: [DisplayItem] = []
    public static var hardwareItem: HardwareItem? = nil
    public static var memoryItems: [MemoryItem] = []
    public static var NVMeItems: [NVMeItem] = []
    public static var powerItems: [PowerItem] = []
    public static var serialATAItems: [SerialATAItem] = []

    public static func getInfo() {
        let launchPath = "/usr/sbin/system_profiler"
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return
        }

        self.getDetailedCPUInfo()

        let infoTask = Process()
        let standardPipe = Pipe()

        infoTask.launchPath = launchPath
        infoTask.arguments = ["-xml", "-detailLevel", "full", "SPDisplaysDataType", "SPHardwareDataType", "SPMemoryDataType", "SPNetworkDataType", "SPPowerDataType", "SPNVMeDataType", "SPSerialATADataType", "DPDiscBurningDataType"]

        infoTask.standardOutput = standardPipe

        print("\(launchPath) \(infoTask.arguments!.joined(separator: " "))")

        let readHandle = standardPipe.fileHandleForReading

        NotificationCenter.default.addObserver(self, selector: #selector(savePropertyListData(_:)), name: FileHandle.readCompletionNotification, object: readHandle)
        NotificationCenter.default.addObserver(self, selector: #selector(parseAllData(_:)), name: Process.didTerminateNotification, object: nil)

        infoTask.launch()
        readHandle.readInBackgroundAndNotify()
    }

    private static func getDetailedCPUInfo() {
        let launchPath = "/usr/sbin/sysctl"
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return
        }

        let infoTask = Process()
        let standardPipe = Pipe()

        infoTask.launchPath = launchPath
        infoTask.arguments = ["-n", "machdep.cpu.brand_string"]
        infoTask.standardOutput = standardPipe

        let readHandle = standardPipe.fileHandleForReading

        NotificationCenter.default.addObserver(self, selector: #selector(saveDetailedCPUInfoData(_:)), name: FileHandle.readCompletionNotification, object: readHandle)
        NotificationCenter.default.addObserver(self, selector: #selector(parseAllData(_:)), name: Process.didTerminateNotification, object: nil)

        infoTask.launch()
        readHandle.readInBackgroundAndNotify()
    }

    @objc static func savePropertyListData(_ notification: Notification) {
        if let fileHandle = notification.object as? FileHandle,
            let userInfo = notification.userInfo as? [String: Any],
            let newData = userInfo[NSFileHandleNotificationDataItem] as? Data, newData.count > 0 {

            print("Appending to propertyListData")
            self.propertyListData.append(newData)

            fileHandle.readInBackgroundAndNotify()
        }
    }

    @objc static func saveDetailedCPUInfoData(_ notification: Notification) {
        if let fileHandle = notification.object as? FileHandle,
            let userInfo = notification.userInfo as? [String: Any],
            let newData = userInfo[NSFileHandleNotificationDataItem] as? Data, newData.count > 0 {

            print("Appending to detailedCPUInfoData")
            self.detailedCPUInfoData.append(newData)

            fileHandle.readInBackgroundAndNotify()
        }
    }

    @objc static func parseAllData(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.propertyListData.count > 0, self.detailedCPUInfoData.count > 0, !hasParsed {
                self.hasParsed = true
                self.parseInto(self.propertyListData)
            }
        }
    }

    public static func condense() -> CondensedSystemProfilerData {
        var allData: [[ItemType]] = [self.audioItems, self.discBurningItems, self.displayItems,
            self.memoryItems, self.NVMeItems, self.powerItems, self.NVMeItems]

        if let validHardwareItem = self.hardwareItem {
            allData.append([validHardwareItem])
        }

        return CondensedSystemProfilerData(from: allData)
    }

    private static func matchTypes(_ unmatchedItems: [SystemProfilerItem]) {
        for anItem in unmatchedItems {
            switch anItem.dataType {
            case .audio:
                self.audioItems = anItem.getItems(AudioItem.self)
                break
            case .discBurning:
                self.discBurningItems = anItem.getItems(DiscBurningItem.self)
                break
            case .display:
                self.displayItems = anItem.getItems(DisplayItem.self)
                break
            case .hardware:
                self.hardwareItem = anItem.getItems(HardwareItem.self).first
                break
            case .memory:
                self.memoryItems = anItem.getItems(MemoryItem.self)
                break
            case .NVMe:
                self.NVMeItems = anItem.getItems(NVMeItem.self)
                break
            case .power:
                self.powerItems = anItem.getItems(PowerItem.self)
                break
            case .serialATA:
                self.serialATAItems = anItem.getItems(SerialATAItem.self)
                break
            case .invalid:
                print("Invalid Item: \(anItem)")
                break
            }
        }
    }

    static func parseInto(_ data: Data) {
        do {
            let decoder = PropertyListDecoder()

            SystemProfilerItem.register(DisplayItem.self, for: .display)
            SystemProfilerItem.register(HardwareItem.self, for: .hardware)
            SystemProfilerItem.register(NestedMemoryItem.self, for: .memory)
            SystemProfilerItem.register(NestedAudioItem.self, for: .audio)
            SystemProfilerItem.register(PowerItem.self, for: .power)
            SystemProfilerItem.register(NVMeItem.self, for: .NVMe)
            SystemProfilerItem.register(DiscBurningItem.self, for: .discBurning)
            SystemProfilerItem.register(SerialATAControllerItem.self, for: .serialATA)

            self.matchTypes(try decoder.decode([SystemProfilerItem].self, from: data))

            if let validHardwareItem = self.hardwareItem,
                let detailedCPUInfo = String(data: detailedCPUInfoData, encoding: .utf8) {
                validHardwareItem.cpuType = detailedCPUInfo.condenseWhitespace()
            }

            if let _delegate = self.delegate {
                _delegate.dataParsedSuccessfully()
            } else {
                print("Data parsed successfully")
            }

        } catch {
            self.hasParsed = false
            if let _delegate = self.delegate {
                _delegate.handleError(error)
            } else {
                print("Error parsing SystemProfilerData: \(error)")
            }
        }
    }
}

enum SPDataType: String {
    case display = "SPDisplaysDataType"
    case hardware = "SPHardwareDataType"
    case memory = "SPMemoryDataType"
    case audio = "SPAudioDataType"
    case power = "SPPowerDataType"
    case NVMe = "SPNVMeDataType"
    case discBurning = "DPDiscBurningDataType"
    case serialATA = "SPSerialATADataType"
    case invalid = "SPInvalidDataType"
}

protocol SystemProfilerDelegate {
    func dataParsedSuccessfully()
    func handleError(_ error: Error)
}
