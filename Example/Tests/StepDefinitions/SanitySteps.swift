//
//  SanitySteps.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class SanitySteps : StepDefiner {
    
    override func defineSteps() {
        
        // Example of defining a step with no capture groups
        step("I have a working Gherkin environment") {
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
        
        step("The age should be ([0-9]*)") { (matches:[String]) in
            XCTAssertEqual(matches.first!, "20", "Alice and Bob are both aged 20, making this test pretty easy.")
        }
        
    }
    
}
