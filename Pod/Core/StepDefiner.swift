//
//  StepDefiner.swift
//  whats-new
//
//  Created by Sam Dean on 29/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import XCTest

extension NSRegularExpression.Options {
    /// Match full string. Equivalent to adding `^` and `$` and the start and end of expression.
    public static let matchesFullString = NSRegularExpression.Options(rawValue: 1 << 20)
}

/**
Classes which extend this class will be queried by the system to
populate the step definitions before test runs
*/
open class StepDefiner: NSObject, XCTestObservation {
    public private(set) var test: XCTestCase

    /// Options to configure steps regular expressions. Default is `[.caseInsensitive]`
    public let regexOptions: NSRegularExpression.Options

    public required init(test: XCTestCase, regexOptions: NSRegularExpression.Options = [.caseInsensitive]) {
        self.test = test
        self.regexOptions = regexOptions

        super.init()

        XCTestObservationCenter.shared.addTestObserver(self)
    }

    deinit {
        XCTestObservationCenter.shared.removeTestObserver(self)
    }

    public func testCaseWillStart(_ testCase: XCTestCase) {
        self.test = testCase
    }
    
    /**
      Override this to create your own step definitions
     */
    open func defineSteps() -> Void { }

    /**
     Create a new step with an expression that contains no matching groups.
         
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
         
         step("Some regular expression") {
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f: The step definition to be run
     
     */
    open func step(_ expression: String, file: String = #file, line: Int = #line, f: @escaping ()->()) {
        self.test.addStep(expression, options: regexOptions, file: file, line: line) { _ in f() }
    }

    /**
     Create a step which _exactly_ matches the passed in string.

     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:

         step(exactly: "Some string literal") {
             ... some function ...
         }

     - parameter exactly: The expression to _exactly_ match against
     - parameter f: The step definition to be run
     */
    open func step(exactly exact: String, file: String = #file, line: Int = #line, f: @escaping ()->()) {
        let expression = NSRegularExpression.escapedPattern(for: exact)
        self.test.addStep("^"+expression+"$", options: regexOptions, file: file, line: line) { _ in f() }
    }

    /**
     Create a new step with an expression that contains one or more matching groups.
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression with a number ([0-9]*)") { (matches:[String]) in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f: The step definition to be run, passing in the matches from the expression
     
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f: @escaping ([T])->()) {
        self.test.addStep(expression, options: regexOptions, file: file, line: line) { matches in
            var converted = [T]()
            for match in matches.allMatches {
                let convert = requireToConvert(T(fromMatch: match), match, expression)
                converted.append(convert)
            }

            f(converted)
        }
    }

    /**
     Create a new step with an expression that contains one or more matching groups. You can mix named and regular groups.

     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:

         step("Some (regular|irregular) expression with (?<aNumber>[0-9]*)") { (matches: StepMatches<String>) in
            let expressionType = matches[0]
            let number = matchs["aNumber"]
            ... some function ...
         }

     - parameter expression: The expression to match against.
     - parameter f: The step definition to be run, passing in the matches from the expression. Matches can be accessed by index or name of the corresponding group

     */
    @available(iOS 11.0, OSX 10.13, *)
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f: @escaping (StepMatches<T>)->()) {
        self.test.addStep(expression, options: regexOptions, file: file, line: line) { (matches: StepMatches<String>) in
            let values = matches.map { match in
                requireToConvert(T(fromMatch: match), match, expression)
            }
            f(values)
        }
    }

    /**
     If you only want to match the first parameter, this will help make your code nicer
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression") { (match: String) in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f: The step definition to be run, passing in the first capture group from the expression
     */
    open func step<T: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f: @escaping (T)->()) {
        self.test.addStep(expression, options: regexOptions, file: file, line: line) { matches in
            precondition(matches.count >= 1, "Expected single match in \"\(expression)\"")
            let match = matches[0]
            let value = requireToConvert(T(fromMatch: match), match, expression)
            f(value)
        }
    }

    /**
     Create a new step with an expression that contains one matching group to match collection of `MatchedStringRepresentable` values

     - parameter expression: The expression to match against
     - parameter f: The step definition to be run, passing in the first capture group from the expression
    */
    open func step<T: Collection & MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f: @escaping (T)->()) {
        self.test.addStep(expression, options: regexOptions, file: file, line: line) { matches in
            precondition(matches.count >= 1, "Expected single match in \"\(expression)\"")
            let match = matches[0]
            let value = requireToConvert(T(fromMatch: match), match, expression)
            f(value)
        }
    }

    /**
     If you only want to match the first two parameters, this will help make your code nicer
     
     Don't pass anything for file: or line: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression with a second capture group here (.*)") { (match1: String, match2: Int) in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f: The step definition to be run, passing in the first two capture groups from the expression
     */
    open func step<T: MatchedStringRepresentable, U: MatchedStringRepresentable>(_ expression: String, file: String = #file, line: Int = #line, f: @escaping (T, U)->()) {
        self.test.addStep(expression, options: regexOptions, file: file, line: line) { (matches: StepMatches) in
            precondition(matches.count >= 2, "Expected at least 2 matches, found \(matches.count) instead, from \"\(expression)\"")
            let (match1, match2) = (matches[0], matches[1])

            let i1 = requireToConvert(T(fromMatch: match1), match1, expression)
            let i2 = requireToConvert(U(fromMatch: match2), match2, expression)

            f(i1, i2)
        }
    }

    /**
     Run other steps from inside your overridden defineSteps() method.
     
     Just do:
     
         step("Some Other Step")
     
     - parameter expression: A string which should match another step definition's regular expression

     */
    open func step(_ expression: String) {
        self.test.performStep(expression, keyword: "")
    }
}
