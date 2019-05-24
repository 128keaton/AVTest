//
//  SystemProfiler.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
import STPrivilegedTask

class SystemProfiler {
    private static var propertyListData: Data = Data()

    public static func getInfo() {
        let launchPath = "/usr/sbin/system_profiler"
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return
        }

        let infoTask = STPrivilegedTask()

        infoTask.setLaunchPath(launchPath)
        infoTask.setArguments(["-xml", "-detailLevel", "full", "SPAudioDataType", "SPBluetoothDataType", "SPCameraDataType", "SPCardReaderDataType", "SPDiagnosticsDataType", "SPDisplaysDataType", "SPHardwareDataType", "SPMemoryDataType", "SPNetworkDataType", "SPPowerDataType", "SPNVMeDataType", "SPAirPortDataType", "SPSerialATADataType", "DPDiscBurningDataType"])


        let launchStatus: OSStatus = infoTask.launch()

        if launchStatus == errAuthorizationSuccess {
            print("Launching task \(infoTask)")
        } else {
            print("Could not authorize task")
        }

        let readHandle = infoTask.outputFileHandle()

        NotificationCenter.default.addObserver(self, selector: #selector(savePropertyListData(_:)), name: FileHandle.readCompletionNotification, object: readHandle)
        NotificationCenter.default.addObserver(self, selector: #selector(parsePropertyListData(_:)), name: NSNotification.Name(rawValue: STPrivilegedTaskDidTerminateNotification), object: nil)

        readHandle?.readInBackgroundAndNotify()
    }

    public static func testGetInfo() {
        let launchPath = "/usr/sbin/system_profiler"
        if !FileManager.default.isExecutableFile(atPath: launchPath) {
            return
        }

        let infoTask = Process()
        let standardPipe = Pipe()

        infoTask.launchPath = launchPath
        infoTask.arguments = ["-xml", "-detailLevel", "full", "SPAudioDataType", "SPBluetoothDataType", "SPCameraDataType", "SPCardReaderDataType", "SPDiagnosticsDataType", "SPDisplaysDataType", "SPHardwareDataType", "SPMemoryDataType", "SPNetworkDataType", "SPPowerDataType", "SPNVMeDataType", "SPAirPortDataType", "SPSerialATADataType", "DPDiscBurningDataType"]

        infoTask.standardOutput = standardPipe


        let readHandle = standardPipe.fileHandleForReading

        NotificationCenter.default.addObserver(self, selector: #selector(savePropertyListData(_:)), name: FileHandle.readCompletionNotification, object: readHandle)
        NotificationCenter.default.addObserver(self, selector: #selector(parsePropertyListData(_:)), name: Process.didTerminateNotification, object: nil)

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

    @objc static func parsePropertyListData(_ notification: Notification) {
        // Cooldown :)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("Done!")
            if self.propertyListData.count > 0{
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
            print(systemProfilerData)
        } catch {
            print(error)
        }
    }
}
