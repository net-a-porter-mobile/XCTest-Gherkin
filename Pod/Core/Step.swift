//
//  Step.swift
//  whats-new
//
//  Created by Sam Dean on 26/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

public struct StepMatches<T: MatchedStringRepresentable> {
    let allMatches: [T]
    let namedMatches: [String: T]

    public var count: Int {
        return allMatches.count
    }

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
    let groupsNames: [String]
    
    /**
     Create a new Step definition with an expression to match against and a function to be
     run when it matches.
     
     The `file` and `line` parameters are for debugging; they should show where the step was
     initially defined.
     */
    init(_ expression: String, options: NSRegularExpression.Options, file: String, line: Int, _ function: @escaping (StepMatches<String>)->() ) {
        self.expression = expression
        self.function = function
        self.file = file
        self.line = line

        if #available(iOS 11.0, OSX 10.13, *) {
            let namedGroupExpr = try! NSRegularExpression(pattern: "(\\(\\?<(\\w+)>.+?\\))")
            groupsNames = namedGroupExpr.matches(in: expression, range: NSMakeRange(0, expression.count)).map { namedGroupMatch in
                return (expression as NSString).substring(with: namedGroupMatch.range(at: 2))
            }
        } else {
            groupsNames = []
        }

        var pattern = expression
        if options.contains(.matchesFullString) {
            if !expression.hasPrefix("^") {
                pattern = "^\(expression)"
            }
            if !expression.hasSuffix("$") {
                pattern = "\(expression)$"
            }
        }
        self.regex = try! NSRegularExpression(pattern: pattern, options: options)
    }

    func matches(from match: NSTextCheckingResult, expression: String) -> (matches: StepMatches<String>, stepDescription: String) {
        var debugDescription = expression
        var namedMatches = [String: String]()

        if #available(iOS 11.0, OSX 10.13, *) {
            groupsNames.forEach { (groupName) in
                let range = match.range(withName: groupName)
                let value = (expression as NSString).substring(with: range)
                debugDescription = (debugDescription as NSString).replacingCharacters(in: range, with: groupName.humanReadableString.lowercased())
                namedMatches[groupName] = value
            }
        }

        let allMatches = (1..<match.numberOfRanges).compactMap { at -> String? in
            let range = match.range(at: at)
            guard range.location != NSNotFound else {
                return nil
            }
            return (expression as NSString).substring(with: range)
        }
        return (StepMatches(allMatches: allMatches, namedMatches: namedMatches), debugDescription)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(expression)
        hasher.combine(file)
        hasher.combine(line)
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

