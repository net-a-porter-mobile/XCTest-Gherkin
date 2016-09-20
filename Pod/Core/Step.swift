//
//  Step.swift
//  whats-new
//
//  Created by Sam Dean on 26/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

/**
 Represents a single step definition - create it with the expression and the 
 test to run as a block.
*/
class Step : Hashable, Equatable, CustomDebugStringConvertible {
    let expression:String
    let function:([String])->()
    
    fileprivate let file: String
    fileprivate let line: Int
    
    // Compute this as part of init
    let regex:NSRegularExpression
    
    /**
     Create a new Step definition with an expression to match against and a function to be
     run when it matches.
     
     The `file` and `line` parameters are for debugging; they should show where the step was
     initially defined.
     */
    init(_ expression: String, file: String, line: Int, _ function: @escaping ([String])->() ) {
        self.expression = expression
        self.function = function
        self.file = file
        self.line = line
        
        // Just throw here; the test will fail :)
        self.regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.caseInsensitive)
    }
    
    var hashValue: Int {
        get {
            return expression.hashValue
        }
    }
    
    var debugDescription: String {
        get {
            // We only want the output the final filename part of `file`
            let name = (file as NSString).lastPathComponent
            
            return ColorLog.green("/\(expression)/") + ColorLog.gray("  (\(name):\(line))")
        }
    }
}

func ==(lhs: Step, rhs: Step) -> Bool {
    return lhs.expression == rhs.expression
}
