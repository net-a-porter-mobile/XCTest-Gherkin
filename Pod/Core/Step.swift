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
            let namedGroup = try! NSRegularExpression(pattern: "(\\(\\?<(\\w+)>.+\\))")
            let namedGroups = namedGroup.matches(in: self.expression, range: NSMakeRange(0, self.expression.count))
            if !namedGroups.isEmpty {
                var debugDescription = self.expression
                let matches: [String: String] = .init(uniqueKeysWithValues: namedGroups.map { (namedGroupMatch) -> (String, String) in
                    let groupName = (self.expression as NSString).substring(with: namedGroupMatch.range(at: 2))
                    debugDescription = (debugDescription as NSString).replacingCharacters(in: namedGroupMatch.range(at: 1), with: groupName.humanReadableString.lowercased())

                    let range = match.range(withName: groupName)
                    let string = range.location != NSNotFound ? (expression as NSString).substring(with: range) : ""
                    return (groupName, string)
                })

                return (matches, debugDescription)
            }
        }

        // Covert them to strings to pass back into the step function
        let matchStrings = (1..<match.numberOfRanges).map {
            (expression as NSString).substring(with: match.range(at: $0))
        }
        return (matchStrings, expression)
    }

    var hashValue: Int {
        return expression.hashValue
    }
    
    var debugDescription: String {
        return "/\(expression)/  \(shortLocationDescription)"
    }

    var fullLocationDescription: String {
        return "(\(file):\(line))"
    }

    var shortLocationDescription: String {
        return "(\((file as NSString).lastPathComponent):\(line))"
    }

}

func ==(lhs: Step, rhs: Step) -> Bool {
    return lhs.expression == rhs.expression
}

extension Collection where Element == Step {
    func printStepsDefinitions() {
        print("-------------")
        print("Defined steps")
        print("-------------")
        print(self.map { String(reflecting: $0) }.sorted { $0.lowercased() < $1.lowercased() }.joined(separator: "\n"))
        print("-------------")
    }
}

extension Collection where Element == String {
    func printAsTemplatedCodeForAllMissingSteps(suggestedSteps: (String) -> [Step]) {
        print("Copy paste these steps in a StepDefiner subclass:")
        print("-------------")
        self.forEach {
            print("step(\"\($0)"+"\") {XCTAssertTrue(true)}")
            let suggestedSteps = suggestedSteps($0)
            if !suggestedSteps.isEmpty {
                print("-------------\nOr maybe you meant one of these steps:\n-------------")
                print(suggestedSteps.map { String(reflecting: $0) }.joined(separator: "\n"))
            }
        }
        print("-------------")
    }

    func printAsUnusedSteps() {
        print("-------------")
        print("Unused steps")
        print("-------------")
        print(self.sorted { $0.lowercased() < $1.lowercased() }.joined(separator: "\n"));
        print("-------------")
    }
}

