//
//  NSTextField+Autosizing.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/24/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa

extension NSTextField {
    func sizeToFitText(minimumFontSize: CGFloat = 12.0) {
        var sizeNotOkay = true
        var attempt = 0
        
        let fontManager = NSFontManager()

        while sizeNotOkay || attempt < 15 { // will try 15 times maximun
            let expansionRect = self.expansionFrame(withFrame: self.frame)

            let truncated = !NSEqualRects(NSRect.zero, expansionRect)

            if truncated {
                if let currentFont = self.font,
                    let actualFontSize = currentFont.fontDescriptor.object(forKey: NSFontDescriptor.AttributeName.size) as? CGFloat {
                 
                    let currentFontWeight = NSFont.Weight(CGFloat(fontManager.weight(of: currentFont)))
                    self.font = NSFont.systemFont(ofSize: (actualFontSize - 0.5), weight: currentFontWeight)

                    if actualFontSize < minimumFontSize {
                        break
                    }
                }
            } else {
                sizeNotOkay = false
            }

            attempt += 1
        }
        
    }
}
