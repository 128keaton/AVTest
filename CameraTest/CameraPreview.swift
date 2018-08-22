//
//  CameraPreview.swift
//  CameraTest
//
//  Created by Keaton Burleson on 8/22/18.
//  Copyright © 2018 Keaton Burleson. All rights reserved.
//

import Foundation
import AppKit

class CameraPreview: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.layer?.cornerRadius = 4
        self.wantsLayer = true
    }
}
