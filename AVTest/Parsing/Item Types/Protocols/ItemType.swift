//
//  ItemType.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

protocol ItemType: Codable {
    var dataType: String { get }
}
