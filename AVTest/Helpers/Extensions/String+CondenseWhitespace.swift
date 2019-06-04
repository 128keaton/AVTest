//
//  String+CondenseWhitespace.swift
//  AVTest
//
//  Created by Keaton Burleson on 6/3/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
