//
//  Step.swift
//  whats-new
//
//  Created by Sam Dean on 26/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

public struct StepMatches<T: MatchedStringRepresentable> {
    public let allMatches: [T]
    public let namedMatches: [String: T]

    public subscript(_ index: Int) -> T {
        return allMatches[index]
    }

    public subscript(_ key: String) -> T? {
        return namedMatches[key]
    }

    public func map<U: MatchedStringRepresentable>(_ f: (T) -> U) -> StepMatches<U> {
        return StepMatches<U>(allMatches: allMatches.map(f), namedMatches: namedMatches.mapValues(f))
    }
}

/**
 Represents a single step definition - create it with the expression and the 
 test to run as a block.
*/
class Step: Hashable, Equatable, CustomDebugStringConvertible {
    let expression: String
    let function: (StepMatches<String>)->()
    
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
    init(_ expression: String, file: String, line: Int, _ function: @escaping (StepMatches<String>)->() ) {
        self.expression = expression
        self.function = function
        self.file = file
        self.line = line
        
        // Just throw here; the test will fail :)
        self.regex = try! NSRegularExpression(pattern: expression, options: .caseInsensitive)
    }

    func matches(from match: NSTextCheckingResult, expression: String) -> (matches: StepMatches<String>, stepDescription: String) {
        var debugDescription = expression
        var namedMatches = [String: String]()

        if #available(iOS 11.0, OSX 10.13, *) {
            let namedGroup = try! NSRegularExpression(pattern: "(\\(\\?<(\\w+)>.+?\\))")
            namedGroup.matches(in: self.expression, range: NSMakeRange(0, self.expression.count)).forEach { (namedGroupMatch) in
                let groupName = (self.expression as NSString).substring(with: namedGroupMatch.range(at: 2))
                let range = match.range(withName: groupName)
                let value = (expression as NSString).substring(with: range)
                debugDescription = (debugDescription as NSString).replacingCharacters(in: range, with: groupName.humanReadableString.lowercased())
                namedMatches[groupName] = value
            }
        }

        let allMatches = (1..<match.numberOfRanges).map {
            (expression as NSString).substring(with: match.range(at: $0))
        }
        return (StepMatches(allMatches: allMatches, namedMatches: namedMatches), debugDescription)
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
