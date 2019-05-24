//
//  NSView+Animations.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/24/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Cocoa

extension NSView {
    public func hide(animated: Bool = true, completion: @escaping () -> () = { }) {
        if !animated {
            self.alphaValue = 0.0
            completion()
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.5
            self.animator().alphaValue = 0.0
        }) {
            completion()
        }
    }
    
    public func show(animated: Bool = true, completion: @escaping () -> () = { }) {
        if !animated {
            self.alphaValue = 1.0
            completion()
        }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.5
            self.animator().alphaValue = 1.0
        }) {
            completion()
        }
    }
}
