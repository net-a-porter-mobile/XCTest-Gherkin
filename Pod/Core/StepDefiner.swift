//
//  StepDefiner.swift
//  whats-new
//
//  Created by Sam Dean on 29/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import XCTest

/**
Classes which extend this class will be queried by the system to
populate the step definitions before test runs
*/
public class StepDefiner {
    public let test: XCTestCase
    
    required public init(test: XCTestCase) {
        self.test = test
    }
    
    /**
      Override this to create your own step definitions
     */
    public func defineSteps() -> Void { }

    /**
     Create a new step with an expression that contains no matching groups.
         
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
         
         step("Some regular expression") {
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f0: The step definition to be run
     
     */
    public func step(expression: String, file: String = #file, line: Int = #line, f0: ()->()) {
        self.test.addStep(expression, file: file, line: line) { (ignored:[String]) in f0() }
    }

    /**
     Create a new step with an expression that contains one or more matching groups.
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression with a number ([0-9]*)") { (matches:[String]) in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f1: The step definition to be run, passing in the matches from the expression
     
     */
    public func step(expression: String, file: String = #file, line: Int = #line, f1: ([String])->()) {
        self.test.addStep(expression, file: file, line: line, f1)
    }
    
    /**
     If you only want to match the first parameter, this will help make your code nicer
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression") { (match: String) in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f1s: The step definition to be run, passing in the first capture group from the expression
     */
    public func step(expression: String, file: String = #file, line: Int = #line, f1s: (String)->()) {
        self.test.addStep(expression, file: file, line: line) { (matches: [String]) in
            guard let match = matches.first else {
                XCTFail("Expected single match not found in \"\(expression)\"")
                return
            }
            
            f1s(match)
        }
    }
    
    /**
     If you only want to match the first parameter, this will help make your code nicer
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
     step("Some (regular|irregular) expression") { (match: Int) in
     ... some function ...
     }
     
     - parameter expression: The expression to match against
     - parameter f1s: The step definition to be run, passing in the first capture group from the expression
     */
    public func step(expression: String, file: String = #file, line: Int = #line, f1i: (Int)->()) {
        self.test.addStep(expression, file: file, line: line) { (matches: [String]) in
            guard let match = matches.first else {
                XCTFail("Expected single match not found in \"\(expression)\"")
                return
            }
            
            guard let integer = Int(match) else {
                XCTFail("Could not convert \"\(match)\" to an integer")
                return
            }
            
            f1i(integer)
        }
    }
    
    /**
     If you only want to match the first two parameters, this will help make your code nicer
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression with a second capture group here (.*)") { (match1: String, match2: String) in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f2s: The step definition to be run, passing in the first two capture groups from the expression
     */
    public func step(expression: String, file: String = #file, line: Int = #line, f2s: (String, String)->()) {
        self.test.addStep(expression, file: file, line: line) { (matches: [String]) in
            
            guard matches.count >= 2 else {
                XCTFail("Expected at least 2 matches, found \(matches.count) instead, from \"\(expression)\"")
                return
            }
            
            f2s(matches[0], matches[1])
        }
    }
    
    /**
     If you only want to match the first parameters as integers, this will help make your code nicer
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
     step("Some (regular|irregular) expression with a second capture group here (.*)") { (match1: Int, match2: Int) in
     ... some function ...
     }
     
     - parameter expression: The expression to match against
     - parameter f2i: The step definition to be run, passing in the first two capture groups from the expression
     */
    public func step(expression: String, file: String = #file, line: Int = #line, f2i: (Int, Int)->()) {
        self.test.addStep(expression, file: file, line: line) { (matches: [String]) in
            
            guard matches.count >= 2 else {
                XCTFail("Expected at least 2 matches, found \(matches.count) instead, from \"\(expression)\"")
                return
            }
            
            guard let i1 = Int(matches[0]),
                let i2 = Int(matches[1]) else {
                    XCTFail("Could not convert matches (\(matches[0]) and \(matches[1])) to integers, from \"\(expression)\"")
                    return
            }
            
            f2i(i1, i2)
        }
    }
    
    /**
     Run other steps from inside your overridden defineSteps() method.
     
     Just do:
     
         step("Some Other Step")
     
     - parameter expression: A string which should match another step definition's regular expression

     */
    public func step(expression: String) {
        self.test.performStep(expression)
    }
}
