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

    public static func getInfo() {
        let launchPath = "/usr/sbin/system_profiler"
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return
        }

        getDetailedCPUInfo()
        
        let infoTask = Process()
        let standardPipe = Pipe()

        infoTask.launchPath = launchPath
        infoTask.arguments = ["-xml", "-detailLevel", "full", "SPAudioDataType", "SPBluetoothDataType", "SPCameraDataType", "SPCardReaderDataType", "SPDiagnosticsDataType", "SPDisplaysDataType", "SPHardwareDataType", "SPMemoryDataType", "SPNetworkDataType", "SPPowerDataType", "SPNVMeDataType", "SPAirPortDataType", "SPSerialATADataType", "DPDiscBurningDataType"]

        infoTask.standardOutput = standardPipe


        let readHandle = standardPipe.fileHandleForReading

        NotificationCenter.default.addObserver(self, selector: #selector(savePropertyListData(_:)), name: FileHandle.readCompletionNotification, object: readHandle)
        NotificationCenter.default.addObserver(self, selector: #selector(parseAllData(_:)), name: Process.didTerminateNotification, object: nil)

        infoTask.launch()
        readHandle.readInBackgroundAndNotify()
    }

    private static func getDetailedCPUInfo(){
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
            propertyListData.append(newData)

            fileHandle.readInBackgroundAndNotify()
        }
    }

    @objc static func saveDetailedCPUInfoData(_ notification: Notification) {
        if let fileHandle = notification.object as? FileHandle,
            let userInfo = notification.userInfo as? [String: Any],
            let newData = userInfo[NSFileHandleNotificationDataItem] as? Data, newData.count > 0 {
            
            print("Appending to detailedCPUInfoData")
            detailedCPUInfoData.append(newData)
            
            fileHandle.readInBackgroundAndNotify()
        }
    }
    
    @objc static func parseAllData(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.propertyListData.count > 0, self.detailedCPUInfoData.count > 0, !hasParsed {
                hasParsed = true
                self.parseInto(self.propertyListData)
            }
        }
    }

    static func parseInto(_ data: Data) {
        do {
            let decoder = PropertyListDecoder()

            SystemProfilerData.register(DisplayItem.self, for: "SPDisplaysDataType")
            SystemProfilerData.register(HardwareItem.self, for: "SPHardwareDataType")
            SystemProfilerData.register(NestedMemoryItem.self, for: "SPMemoryDataType")
            SystemProfilerData.register(NestedAudioItem.self, for: "SPAudioDataType")
            SystemProfilerData.register(PowerItem.self, for: "SPPowerDataType")
            SystemProfilerData.register(NVMeItem.self, for: "SPNVMeDataType")
            SystemProfilerData.register(DiscBurningItem.self, for: "DPDiscBurningDataType")
            SystemProfilerData.register(SerialATAControllerItem.self, for: "SPSerialATADataType")

            let systemProfilerData = try decoder.decode([SystemProfilerData].self, from: data)

            if let hardwareDataItem = systemProfilerData.first(where: { $0.dataType == "SPHardwareDataType" }),
                let hardwareItem = hardwareDataItem.items?.first(where: { type(of: $0) == HardwareItem.self }) as? HardwareItem,
                let detailedCPUInfo = String(data: detailedCPUInfoData, encoding: .utf8) {
                let formattedCPUInfo = detailedCPUInfo.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "CPU @", with: "-")
                
                hardwareItem.updateCPUInfo(formattedCPUInfo)
            }

            if let _delegate = self.delegate {
                _delegate.dataParsedSuccessfully(systemProfilerData)
            } else {
                print("Data parsed successfully: \(systemProfilerData)")
            }
        } catch {
            hasParsed = false
            if let _delegate = self.delegate {
                _delegate.handleError(error)
            } else {
                print("Error parsing SystemProfilerData: \(error)")
            }
        }
    }
}

protocol SystemProfilerDelegate {
    func dataParsedSuccessfully(_ systemProfilerData: [SystemProfilerData])
    func handleError(_ error: Error)
}
