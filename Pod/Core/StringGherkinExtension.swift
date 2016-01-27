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
            let separators = NSCharacterSet(charactersInString: " -")
            return self.componentsSeparatedByCharactersInSet(separators).filter {
                // Empty sections aren't interesting
                $0.characters.count > 0
            }.map {
                // Uppercase each word
                $0.uppercaseFirstLetterString
            }.joinWithSeparator("")
        }
    }

    /**
     The reciever with the first letter uppercased - the rest of the string remains untouched.
     
     - "hello" -> "Hello"
     - "HeLLO" -> "HeLLO"
    */
    var uppercaseFirstLetterString: String {
        get {
            let s = self as NSString
            return s.substringToIndex(1).uppercaseString.stringByAppendingString(s.substringFromIndex(1))
        }
    }
    
    /**
     Given `CamelCaseString` this will return `Camel Case String`
     
     TODO: There is probably a more efficient way to do this. Technically this is O(n) I guess, just not a very nice O(n).
     */
    var humanReadableString: String {
        get {
            // This is probably easier in NSStringland
            let s = self as NSString
            
            // The output string can start with the first letter
            var o = s.substringToIndex(1)
            
            // For each other letter, if it's the same as it's uppercase counterpart, insert a space before it
            for (var i = 1; i < s.length; ++i) {
                let l = s.substringWithRange(NSMakeRange(i, 1))
                let u = l.uppercaseString
                
                if (u == l) {
                    o += " "
                }
                
                o += l
            }
            
            return o
        }
    }
}
