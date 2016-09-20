//
//  ScreenHelperExtensions.swift
//  whats-new
//
//  Created by Sam Dean on 03/11/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

public extension String {
    
    /**
     Given a human readable string this method will return a 'CamelCaseified' version of it.

     - `"product details".screenName` returns `"ProductDetails"`

    */
    var camelCaseify: String {
        get {
            guard case let c = (self.characters.split { $0 == " " || $0 == "-" })
                , c.count > 1 else {
                return self.uppercaseFirstLetterString
            }
            return c.map { String($0).lowercased().uppercaseFirstLetterString }
                .joined(separator: "")
        }
    }

    /**
     The reciever with the first letter uppercased - the rest of the string remains untouched.
     
     - "hello" -> "Hello"
     - "HeLLO" -> "HeLLO"
    */
    var uppercaseFirstLetterString: String {
        get {
            guard case let c = self.characters,
                let c1 = c.first else { return self }
            return String(c1).uppercased() + String(c.dropFirst())
        }
    }
    
    /**
     Given `CamelCaseString` this will return `Camel Case String`
     
     TODO: There is probably a more efficient way to do this. Technically this is O(n) I guess, just not a very nice O(n).
     */
    var humanReadableString: String {
        get {
            guard case let c = self.characters , c.count > 1,
                let c1 = c.first else { return self }
            return String(c1) + c.dropFirst().reduce("") { (sum, c) in
                let s = String(c)
                if s == s.uppercased() {
                    return sum + " " + s
                }
                else {
                    return sum + s
                }
            }
        }
    }
}
