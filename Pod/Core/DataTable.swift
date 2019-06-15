//
//  DataTable.swift
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 02/09/2018.
//

import Foundation

/**
 Use DataTable as the type of the step parameter to be able to pass collection of values to the step.
 
 Example:
 ```
 Given("I use the following names:") {
    ["Alice", "Bob"]
 }

 step("I use the following names: (.+)") { (match: DataTable<[String]>) in
    ...
 }
 ```
 */
public struct DataTable<T: Collection>: CodableMatchedStringRepresentable where T: Codable {
    public let values: T

    public init(_ values: T) {
        self.values = values
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        self.values = try values.decode(T.self)
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.singleValueContainer()
        try values.encode(self.values)
    }

    public init?(fromMatch match: String) {
        let decoder = JSONDecoder()
        guard let data = match.data(using: .utf8) else {
            return nil
        }
        if let decoded = try? decoder.decode(DataTable<T>.self, from: data) {
            self = decoded
        } else {
            return nil
        }
    }

}

extension DataTable: Equatable where T: Equatable {
    public static func ==(lhs: DataTable<T>, rhs: DataTable<T>) -> Bool {
        return lhs.values == rhs.values
    }
}
