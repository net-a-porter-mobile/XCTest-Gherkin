//
//  TypeConversion.swift
//  Pods
//
//  Created by Sam Dean on 4/4/17.
//
//

import Foundation


public protocol MatchedStringRepresentable {
    init?(fromMatch: String)
}

extension MatchedStringRepresentable where Self: LosslessStringConvertible {
    public init?(fromMatch match: String) {
        self.init(match)
    }
}

extension String: MatchedStringRepresentable { }

extension Double: MatchedStringRepresentable { }

extension Bool: MatchedStringRepresentable {
    public init?(fromMatch match: String) {
        self.init(match.lowercased())
    }
}

extension Int: MatchedStringRepresentable {
    public init?(fromMatch match: String) {
        self.init(match, radix: 10)
    }
}

public protocol CodableMatchedStringRepresentable: Codable, CustomStringConvertible, MatchedStringRepresentable {}

extension CodableMatchedStringRepresentable {
    public init?(fromMatch match: String) {
        let decoder = JSONDecoder()
        guard let data = match.data(using: .utf8),
            let decoded = try? decoder.decode(Self.self, from: data) else {
                return nil
        }
        self = decoded
    }

    public var description: String {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(self)
        return String(data: encoded, encoding: .utf8)!
    }
}
// For some reason extending array with CodableMatchedStringRepresentable makes `pod lint` to fail
// but this way it works and its sufficient as CodableMatchedStringRepresentable is just a composition of protocols 🤷‍♂️
extension Array: MatchedStringRepresentable where Element: CodableMatchedStringRepresentable {
    public init?(fromMatch match: String) {
        let decoder = JSONDecoder()
        guard let data = match.data(using: .utf8),
            let decoded = try? decoder.decode([Element].self, from: data) else {
                return nil
        }
        self = decoded
    }

    public var description: String {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(self)
        return String(data: encoded, encoding: .utf8)!
    }
}
