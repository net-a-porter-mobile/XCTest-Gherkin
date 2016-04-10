//
//  ExampleFeatures.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class ExampleFeatures: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ColorLog.enabled = true
    }

    func testBasicSteps() {
        Given("I have a working Gherkin environment")
        Then("This test should not fail")
    }
    
    func testNestedSteps() {
        Given("This step should call another step")
        Then("This test should not fail")
    }
    
    func testOutlineTests() {
        Examples(
            [ "name", "age" ],
            [ "Alice", "20" ],
            [ "Bob", "20" ]
        )
        
        Outline {
            Given("I use the example name <name>")
            Then("The age should be <age>")
        }
    }
    
    let examples = [
        [ "name",   "age", "height" ],
        [  "Alice",  "20",  "170"   ],
        [  "Bob",    "20",  "170"   ]
    ]
    
    func testReusableExamples1() {
        Examples(examples)
        
        Outline {
            Given("I use the example name <name>")
            Then("The age should be <age>")
        }
    }

    func testReusableExamples2() {
        Examples(examples)
        
        Outline {
            Given("I use the example name <name>")
            Then("The height should be <height>")
        }
    }

    func testExamplesAfterOutline() {
        Outline {
            Given("I use the example name <name>")
            Then("The height should be <height>")
        }

        Examples(
            [ "name", "age" ],
            [ "Alice", "20" ],
            [ "Bob", "20" ]
        )
    }

}
