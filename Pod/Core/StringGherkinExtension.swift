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
            guard case let characters = (self.split { $0 == " " || $0 == "-" }), characters.count > 1 else {
                return self.uppercaseFirstLetterString
            }
            return characters.map { String($0).lowercased().uppercaseFirstLetterString }.joined(separator: "")
        }
    }

    /**
     The reciever with the first letter uppercased - the rest of the string remains untouched.
     
     - "hello" -> "Hello"
     - "HeLLO" -> "HeLLO"
    */
    var uppercaseFirstLetterString: String {
        get {
            guard let firstCharacter = self.first else { return self }
            return String(firstCharacter).uppercased() + String(self.dropFirst())
        }
    }
    
    /**
     Given `CamelCaseString` this will return `Camel Case String`
     
     TODO: There is probably a more efficient way to do this. Technically this is O(n) I guess, just not a very nice O(n).
     */
    var humanReadableString: String {
        get {
            guard self.count > 1, let firstCharacter = self.first else { return self }
            return String(firstCharacter) + self.dropFirst().reduce("") { (word, character) in
                let letter = String(character)
                if letter == letter.uppercased() {
                    return word + " " + letter
                }
                else {
                    return word + letter
                }
            }
        }
    }
}
