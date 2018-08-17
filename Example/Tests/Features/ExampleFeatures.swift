//
//  ExampleFeatures.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

final class ExampleFeatures: XCTestCase {
    
    override func setUp() {
        super.setUp()
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

    let examples: [[ExampleStringRepresentable]] = [
        [ "name",   "age", "height" ],
        [  "Alice",  20,  170   ],
        [  "Bob",    20,  170   ]
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

    func testAccessCurrentExampleValue() {
        Examples(examples)

        Outline {
            let name: String = self.exampleValue("name")!
            let height: String = self.exampleValue("height")!

            Given("I use the example name \(name)")
            Then("The height should be \(height)")
        }
    }

    struct Person: CodableMatchedStringRepresentable {
        let name: String
        let age: Int
        let height: Int
    }

    func testCustomExampleValues() {
        Examples(
            ["person"],
            [Person(name: "Bob", age: 27, height: 170)]
        )

        Outline {
            let person: Person = self.exampleValue("person")!

            Given("I use the example name \(person.name)")
            Then("The height should be \(person.height)")
        }
    }

    func testMatchHelpers() {
        Given("I have a step which has a single match: 1")
        And("I have a step with two matches: 1 2")
        Then("Some value should be 6")
        And("Some value should be between 5 and 7")
    }

    func testGenericMatchHelpers() {
        Given("I have a string hello")
        And("I have an integer 1")
        And("I have a boolean FaLsE")
        And("I have a double 1.2")
        And("I have a double which looks like an int 1")
        And("I have a mixture of types 1.1 hello")
    }

    func testStepAnchorMatching() {
        Given("This is a substring")
    }

    func testCodableMatches() {
        Examples(
            ["person"],
            [Person(name: "Alice", age: 27, height: 170)],
            [Person(name: "Bob", age: 27, height: 170)]
        )

        Outline {
            let person: Person = self.exampleValue("person")!
            Given("I know \(person)")
        }
    }

    func testDataTable() {
        Examples(
            ["persons"],
            [
                [Person(name: "Alice", age: 27, height: 170),
                Person(name: "Bob", age: 27, height: 170)]
            ]
        )

        Outline {
            Given("I know these <persons>")
            
            let persons: [Person] = self.exampleValue("persons")!
            Given("I know these \(persons)")
        }
    }
}
