//
//  SystemProfilerData.swift
//  AVTest
//
//  Created by Keaton Burleson on 5/17/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation

struct SystemProfilerData: Codable {
    var dataType: String
    var items: [Any]?

    enum CodingKeys: String, CodingKey {
        case dataType = "_dataType"
        case parentDataType = "_parentDataType"
        case items = "_items"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dataType = try container.decode(String.self, forKey: .dataType)

        if let decode = SystemProfilerData.decoders[dataType] {
            do {
                items = try decode(container) as? [Any]
            } catch {
               /* if let nestedItems = checkForNested(container, decode: decode){
                    items = nestedItems
                }else{
                    print("Tried to check for a nested decoding scheme, but failed.")
                    print(error)
                    items = nil
                }*/
                
                        print(error)
            }
        } else {
            items = nil
        }
    }

    private func checkForNested(_ container: KeyedDecodingContainer<CodingKeys>, decode: SystemProfilerDataDecoder) -> [Any]? {
        do {
            let nestedItems = try decode(container) as? [String: [Any]]
            return nestedItems?.values.first
        } catch {
            print("Guess it was not nested..")
            print("Nested Decoding Error: \(error)")
        }
        
        return nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(dataType, forKey: .dataType)

        if let items = self.items {
            guard let encode = SystemProfilerData.encoders[dataType] else {
                let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid data type: \(dataType).")
                throw EncodingError.invalidValue(self, context)
            }

            try encode(items, &container)
        } else {
            try container.encodeNil(forKey: .items)
        }
    }

    private typealias SystemProfilerDataDecoder = (KeyedDecodingContainer<CodingKeys>) throws -> Any
    private typealias SystemProfilerDataEncoder = (Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void

    private static var decoders: [String: SystemProfilerDataDecoder] = [:]
    private static var encoders: [String: SystemProfilerDataEncoder] = [:]

    static func register<A: Codable>(_ type: A.Type, for typeName: String) {
        decoders[typeName] = { container in
            try container.decode([A].self, forKey: .items)
        }

        encoders[typeName] = { items, container in
            try container.encode(items as! [A], forKey: .items)
        }
    }
}

