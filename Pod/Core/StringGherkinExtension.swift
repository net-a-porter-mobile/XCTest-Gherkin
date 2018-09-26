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

    var snakeToCamelCase: String {
        return components(separatedBy: "_")
            .filter { !$0.isEmpty }
            .map({ $0.uppercaseFirstLetterString })
            .joined()
    }

    /**
     Given `CaseString` or `case_string` this will return `Case String`
     
     TODO: There is probably a more efficient way to do this. Technically this is O(n) I guess, just not a very nice O(n).
     */
    var humanReadableString: String {
        get {
            let string = self.snakeToCamelCase
            guard string.count > 1 else { return string }
            var words = [String]()
            var word: String = ""
            string.forEach { (character) in
                let letter = String(character)
                let lastIsLetter = !word.isEmpty && String(word.last!).rangeOfCharacter(from: .letters) != nil
                let thisIsLetter = letter.rangeOfCharacter(from: .letters) != nil
                if (letter == letter.uppercased() && lastIsLetter)
                    || (thisIsLetter && !lastIsLetter)
                    && !word.isEmpty {
                    words.append(word)
                    word = letter != " " ? letter : ""
                }
                else {
                    word += letter != " " ? letter : ""
                }
            }
            words.append(word)
            return words.joined(separator: " ")
        }
    }
}
