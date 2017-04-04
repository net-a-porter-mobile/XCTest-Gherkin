//
//  TypeConversion.swift
//  Pods
//
//  Created by Sam Dean on 4/4/17.
//
//

import Foundation


public protocol FromStringable {

    static func fromString(_ string: String) -> Self?

}

extension String: FromStringable {

    public static func fromString(_ string: String) -> String? {
        return String(string)
    }

}

extension Int: FromStringable {

    public static func fromString(_ string: String) -> Int? {
        return Int(string)
    }

}

extension Double: FromStringable {

    public static func fromString(_ string: String) -> Double? {
        return Double(string)
    }
}

extension Bool: FromStringable {

    public static func fromString(_ string: String) -> Bool? {
        return Bool(string.lowercased())
    }
}
