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
        let allowed = CharacterSet(charactersIn: "-").union(.alphanumerics).union(.whitespaces)
        let filtered = self.filter({ CharacterSet(charactersIn: "\($0)").isSubset(of: allowed) })
        guard case let characters = (filtered.split { $0 == " " || $0 == "-" }).filter({ !$0.isEmpty }), characters.count > 1 else {
            return self.uppercaseFirstLetterString
        }
        return characters.map { String($0).lowercased().uppercaseFirstLetterString }.joined(separator: "")
    }

    /**
     The reciever with the first letter uppercased - the rest of the string remains untouched.
     
     - "hello" -> "Hello"
     - "HeLLO" -> "HeLLO"
    */
    var uppercaseFirstLetterString: String {
        guard let firstCharacter = self.first else { return self }
        return String(firstCharacter).uppercased() + String(self.dropFirst())
    }

    func snakeToCamelCase(_ string: String) -> String {
        return string.components(separatedBy: "_")
            .filter { !$0.isEmpty }
            .map({ $0.uppercaseFirstLetterString })
            .joined()
    }

    /**
     Given `CamelCaseString` or `snake_case_string` this will return `Camel Case String`
     
     TODO: There is probably a more efficient way to do this. Technically this is O(n) I guess, just not a very nice O(n).
     */
    var humanReadableString: String {
        let string = snakeToCamelCase(self)
        guard string.count > 1, let firstCharacter = string.first else { return string }
        return String(firstCharacter) + string.dropFirst().reduce("") { (word, character) in
            let letter = String(character)
            let lastIsLetter = !word.isEmpty && String(word.last!).rangeOfCharacter(from: .letters) != nil
            let thisIsLetter = letter.rangeOfCharacter(from: .letters) != nil
            if letter == letter.uppercased() && (lastIsLetter || (!lastIsLetter && thisIsLetter)) {
                return word + " " + letter
            }
            else {
                return word + letter
            }
        }
    }
}
