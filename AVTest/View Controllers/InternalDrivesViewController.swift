//
//  InternalDrivesViewController.swift
//  AVTest
//
//  Created by Keaton Burleson on 6/3/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa

class InternalDrivesViewController: NSViewController {
    @IBOutlet private weak var tableView: NSTableView!

    private var storageItems: [StorageItem] = []
    private let descriptorModel = NSSortDescriptor(key: "model", ascending: true)
    private let descriptorSerial = NSSortDescriptor(key: "serialNumber", ascending: true)
    private let descriptorSize = NSSortDescriptor(key: "size", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.tableColumns[0].sortDescriptorPrototype = descriptorModel
        self.tableView.tableColumns[1].sortDescriptorPrototype = descriptorSerial
        self.tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.loadItems()
    }

    private func loadItems() {
        self.storageItems = []
        self.storageItems.append(contentsOf: SystemProfiler.serialATAItems.filter { !$0.isDiscDrive })
        self.storageItems.append(contentsOf: SystemProfiler.NVMeItems)

        if self.storageItems.count > 0 {
            self.tableView.reloadData()
        }
    }
}

extension InternalDrivesViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.storageItems.count
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }

        storageItems.sort { firstStorageItem, secondStorageItem in
            let comparisonResult = sortDescriptor.ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending
            return firstStorageItem[sortDescriptor.key!].localizedCompare(secondStorageItem[sortDescriptor.key!]) == comparisonResult
        }

        self.tableView.reloadData()
    }


    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let storageItem = self.storageItems[row]

        if tableColumn?.title == "Serial" {
            guard let serialCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "diskSerialCell"), owner: nil) as? NSTableCellView else {
                return nil
            }

            serialCell.textField?.stringValue = storageItem.serialNumber
            return serialCell
        } else if tableColumn?.title == "Model" {
            guard let modelCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "diskModelCell"), owner: nil) as? NSTableCellView else {
                return nil
            }

            var model = String()

            if let NVMeItem = storageItem as? NVMeItem {
                model = NVMeItem.model
            } else if let serialATAItem = storageItem as? SerialATAItem {
                model = serialATAItem.model
            } else {
                print(storageItem)
            }

            modelCell.textField?.stringValue = model
            return modelCell
        } else if tableColumn?.title == "Size" {
            guard let sizeCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "diskSizeCell"), owner: nil) as? NSTableCellView else {
                return nil
            }

            sizeCell.textField?.stringValue = storageItem.size
            return sizeCell
        }

        return nil
    }
}
