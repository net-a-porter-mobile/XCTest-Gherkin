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
    public let test:XCTestCase
    
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
    public func step(expression:String, file:String = #file, line:Int = #line, f0:()->()) {
        self.test.addStep(expression, file: file, line: line) { (ignored:[String]) in f0() }
    }

    /**
     Create a new step with an expression that contains one or more matching groups.
     
     Don't pass anything for file: or path: - these will be automagically filled out for you. Use it like this:
     
         step("Some (regular|irregular) expression") { matches:[String] in
             ... some function ...
         }
     
     - parameter expression: The expression to match against
     - parameter f1: The step definition to be run, passing in the matches from the expression
     
     */
    public func step(expression:String, file:String = #file, line:Int = #line, f1:([String])->()) {
        self.test.addStep(expression, file: file, line: line, f1)
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
