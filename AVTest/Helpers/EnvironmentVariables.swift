//
//  EnvironmentVariables.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/24/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//
//  https://medium.com/@derrickho_28266/xcode-custom-environment-variables-681b5b8674ec

import Foundation

struct EnvironmentVariables: RawRepresentable {
    var rawValue: String
    static let print_server_address = EnvironmentVariables(rawValue: "print_server_address")
    var value: String {
        let readValue = ProcessInfo.processInfo.environment[rawValue]
        return readValue ?? ""
    }
}
