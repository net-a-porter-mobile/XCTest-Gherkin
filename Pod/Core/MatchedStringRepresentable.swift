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
