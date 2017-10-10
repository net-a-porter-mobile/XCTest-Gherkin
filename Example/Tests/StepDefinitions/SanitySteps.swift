//
//  SanitySteps.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

final class SanitySteps: StepDefiner {
    
    private var numberOfExamplesExecutedInOrder = 1
    
    override func defineSteps() {
        
        // Examples of defining a step with no capture groups
        step("I have a working Gherkin environment") {
            XCTAssertTrue(true)
        }
        
        step("I have duplicate steps at the start of every scenario") {
            XCTAssertTrue(true)
        }
        
        step("I should move these steps to the background section") {
            XCTAssertTrue(true)
        }
        
        // Example of a step that captures (and validates) the final word in the
        // expression
        step("This test should not ([a-zA-Z0-9]*)") { (matches: [String]) in
            XCTAssertEqual(matches.first, "fail")
        }
        
        // Example of a nested step definition
        step("This step should call another step") {
            self.step("This is another step")
        }
        
        // This step is only called from another step
        step("This is another step") {
            XCTAssertTrue(true)
        }
        
        // Step definitions dealing with the example test case
        step("I use the example name (?:Alice|Bob)") {
            // If the name isn't Alice or Bob, we won't have matched this step,
            // so no need to verify it here
            XCTAssertTrue(true)
        }
        
        step("The age should be ([0-9]+)") { (matches: [String]) in
            XCTAssertEqual(matches.first!, "20", "Alice and Bob are both aged 20, making this test pretty easy.")
        }
        
        step("The height should be ([0-9]+)") { (matches: [String]) in
            XCTAssertEqual(matches.first!, "170", "Alice and Bob are both 170cm tall, making this test pretty easy.")
        }
        
        // Example of convenience form for the step method, extracting a single match for you
        step("I have a step which has a single match: ([0-9])") { (match: String) in
            XCTAssertEqual(match, "1")
        }
        
        // Example of convenience form for the step method, extracting two string matches for you
        step("I have a step with two matches: ([0-9]) ([0-9])") { (match1: String, match2: String) in
            XCTAssertEqual(match1, "1")
            XCTAssertEqual(match2, "2")
        }
        
        // Example of convenience form for the step method, extracting a single integer match for you
        step("Some value should be ([0-9])") { (match: Int) in
            XCTAssertEqual(match, 6)
        }
        
        // Example of convenience form for the step method, extracting two integer matches for you
        step("Some value should be between ([0-9]) and ([0-9])") { (match1: Int, match2: Int) in
            XCTAssertEqual(match1, 5)
            XCTAssertEqual(match2, 7)
        }
        
        step("This should be executed before A with example value ([0-9])") { (count: Int) in
            XCTAssertEqual(count, self.numberOfExamplesExecutedInOrder)
            self.numberOfExamplesExecutedInOrder += 1
        }
        
        step("This should be executed after") {
            XCTAssertEqual( self.numberOfExamplesExecutedInOrder, 4)
        }

        step("I have a string (.*)") { (match: String) in
            XCTAssertEqual(match, "hello")
        }

        step("I have an integer ([0-9]*)") { (match: Int) in
            XCTAssertEqual(match, 1)
        }

        step("I have a boolean (.*)") { (match: Bool) in
            XCTAssertFalse(match)
        }

        step("I have a double (.*)") { (match: Double) in
            XCTAssertEqual(match, 1.2)
        }

        step("I have a double which looks like an int (.*)") { (match: Double) in
            XCTAssertEqual(match, 1)
        }

        step("I have a mixture of types ([0-9\\.]*) (.*)") { (d: Double, s: String) in
            XCTAssertEqual(d, 1.1)
            XCTAssertEqual(s, "hello")
        }
    }
}
