//
//  Step.swift
//  whats-new
//
//  Created by Sam Dean on 26/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

protocol StepFunctionParameters {}

extension Array: StepFunctionParameters where Element == String {}
extension Dictionary: StepFunctionParameters where Key == String, Value == String {}

/**
 Represents a single step definition - create it with the expression and the 
 test to run as a block.
*/
class Step: Hashable, Equatable, CustomDebugStringConvertible {
    let expression: String
    let function: (StepFunctionParameters)->()
    
    fileprivate let file: String
    fileprivate let line: Int
    
    // Compute this as part of init
    let regex: NSRegularExpression
    
    /**
     Create a new Step definition with an expression to match against and a function to be
     run when it matches.
     
     The `file` and `line` parameters are for debugging; they should show where the step was
     initially defined.
     */
    init(_ expression: String, file: String, line: Int, _ function: @escaping (StepFunctionParameters)->() ) {
        self.expression = expression
        self.function = function
        self.file = file
        self.line = line
        
        // Just throw here; the test will fail :)
        self.regex = try! NSRegularExpression(pattern: expression, options: .caseInsensitive)
    }

    func matches(from match: NSTextCheckingResult, expression: String) -> (matches: StepFunctionParameters, stepDescription: String) {
        if #available(iOS 11.0, OSX 10.13, *) {
            let namedGroup = try! NSRegularExpression(pattern: "(\\(\\?<(\\w+)>.+?\\))")
            var debugDescription = expression
            var namedMatches = [String: String]()
            namedGroup.matches(in: self.expression, range: NSMakeRange(0, self.expression.count)).forEach { (namedGroupMatch) in
                let groupName = (self.expression as NSString).substring(with: namedGroupMatch.range(at: 2))
                let range = match.range(withName: groupName)
                let value = (expression as NSString).substring(with: range)
                debugDescription = (debugDescription as NSString).replacingCharacters(in: range, with: groupName.humanReadableString.lowercased())
                namedMatches[groupName] = value
            }
            if !namedMatches.isEmpty {
                var allMatches = (1..<match.numberOfRanges).reduce(into: [String: String]()) { current, index in
                    current["\(index)"] = (expression as NSString).substring(with: match.range(at: index))
                }
                allMatches.merge(namedMatches, uniquingKeysWith: { $1 })

                return (allMatches, debugDescription)
            }
        }

        // Covert them to strings to pass back into the step function
        let matchStrings = (1..<match.numberOfRanges).map {
            (expression as NSString).substring(with: match.range(at: $0))
        }
        return (matchStrings, expression)
    }

    var hashValue: Int {
        get {
            return expression.hashValue
        }
    }
    
    var debugDescription: String {
        get {
            return "/\(expression)/  \(locationDescription)"
        }
    }

    var locationDescription: String {
        // We only want the output the final filename part of `file`
        let name = (file as NSString).lastPathComponent
        return "(\(name):\(line))"
    }
}

func ==(lhs: Step, rhs: Step) -> Bool {
    return lhs.expression == rhs.expression
}
