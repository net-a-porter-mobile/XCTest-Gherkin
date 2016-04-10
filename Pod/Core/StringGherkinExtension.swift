//
//  ScreenHelperExtensions.swift
//  whats-new
//
//  Created by Sam Dean on 03/11/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

public extension String {
    
    /**
     Given a human readable string this method will return a 'CamelCaseified' version of it.

     - `"product details".screenName` returns `"ProductDetails"`

    */
    var camelCaseify: String {
        get {
            return self.characters
                .split { $0 == " " || $0 == "-" }
                .map { String($0).uppercaseFirstLetterString }
                .joinWithSeparator("")
        }
    }

    /**
     The reciever with the first letter uppercased - the rest of the string remains untouched.
     
     - "hello" -> "Hello"
     - "HeLLO" -> "HeLLO"
    */
    var uppercaseFirstLetterString: String {
        get {
            let c = self.characters
            return String(c.prefix(1)).uppercaseString +
                String(c.suffixFrom(c.startIndex.advancedBy(1, limit: c.endIndex)))
        }
    }
    
    /**
     Given `CamelCaseString` this will return `Camel Case String`
     
     TODO: There is probably a more efficient way to do this. Technically this is O(n) I guess, just not a very nice O(n).
     */
    var humanReadableString: String {
        get {
            guard let c1 = self.characters.first else { return self }
            
            let cRest = self.characters
                .suffixFrom(self.characters.startIndex.successor())
            
            return String(c1) + cRest.reduce("") { (sum, c) in
                let s = String(c)
                if s == s.uppercaseString {
                    return sum + " " + s
                }
                else {
                    return sum + s
                }
            }
        }
    }
}
