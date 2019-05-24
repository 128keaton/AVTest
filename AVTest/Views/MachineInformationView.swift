//
//  MachineInformationView.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/24/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
import AppKit

class MachineInformationView: NSView {
    @IBOutlet private var machineModelField: NSTextField!
    @IBOutlet private var machineMemoryField: NSTextField!
    @IBOutlet private var machineProcessorField: NSTextField!

    @IBOutlet private var printButton: NSButton!
    @IBOutlet private var contentBox: NSBox!

    public var delegate: MachineInformationViewDelegate? = nil

    private (set) public var machineModel: String = ""
    private (set) public var machineMemory: String = ""
    private (set) public var machineProcesser: String = ""

    private (set) public var fieldsPopulated: Bool = false {
        didSet {
            if self.fieldsPopulated {
                self.layoutFields()
            }
        }
    }

    init(frame frameRect: NSRect, hidden: Bool, systemProfilerData passedData: [SystemProfilerData]) {
        super.init(frame: frameRect)

        if hidden {
            self.alphaValue = 0.0
        }

        loadInterface()
        populateFields(withData: passedData)
    }

    init(frame frameRect: NSRect, hidden: Bool) {
        super.init(frame: frameRect)

        if hidden {
            self.alphaValue = 0.0
        }

        loadInterface()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        loadInterface()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)

        loadInterface()
    }

    private func populateFields(withData systemProfilerData: [SystemProfilerData]) {
        if let hardwareDataItem = systemProfilerData.first(where: { $0.dataType == "SPHardwareDataType" }),
            let hardwareItem = hardwareDataItem.items?.first(where: { type(of: $0) == HardwareItem.self }) as? HardwareItem {

            machineModelField.stringValue = hardwareItem.machineModel
            machineMemoryField.stringValue = hardwareItem.physicalMemory
            machineProcessorField.stringValue = hardwareItem.cpuType

            fieldsPopulated = true
            return
        }

        fieldsPopulated = false
    }

    private func layoutFields() {
        machineModelField.sizeToFitText()
        machineProcessorField.sizeToFitText()
        machineMemoryField.sizeToFitText()
        
        machineModelField.delegate = self
        machineProcessorField.delegate = self
        machineMemoryField.delegate = self
        
        machineModel = machineModelField.stringValue
        machineProcesser = machineProcessorField.stringValue
        machineMemory = machineMemoryField.stringValue
    }

    private func loadInterface() {
        Bundle.main.loadNibNamed("MachineInformationView", owner: self, topLevelObjects: nil)
        addSubview(contentBox)
        contentBox.frame = self.bounds
        contentBox.autoresizingMask = [.height, .width]
    }

    @IBAction func printButtonClicked(_ sender: NSButton) {
        self.delegate?.printButtonClicked()
    }
}

extension MachineInformationView: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            if textField == machineMemoryField {
                self.machineMemory = textField.stringValue
            } else if textField == machineModelField {
                self.machineModel = textField.stringValue
            } else if textField == machineProcessorField {
                self.machineProcesser = textField.stringValue
            }
        }
    }
}
protocol MachineInformationViewDelegate {
    func printButtonClicked()
}
