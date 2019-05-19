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
            if self.propertyListData.count > 0,
                let rawPropertyList = String(data: self.propertyListData, encoding: .utf8),
                self.testSaveToFile(fileName: "SystemProfiler", writeText: rawPropertyList) {
                self.parseInto(self.propertyListData)
                print("Wrote file!")
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

    static func testParse() {
        let fileName = "SystemProfiler"
        let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let filePath = desktopURL.appendingPathComponent(fileName).appendingPathExtension("plist").absoluteString
        if let data = FileManager.default.contents(atPath: filePath.replacingOccurrences(of: "file://", with: "")) {
            parseInto(data)
        }
    }

    static func testSaveToFile(fileName: String, writeText: String) -> Bool {
        let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = desktopURL.appendingPathComponent(fileName).appendingPathExtension("plist")

        print("File Path: \(fileURL.path)")

        do {
            try writeText.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Error: fileURL failed to write: \n\(error)")
            return false
        }
        return true
    }
}
