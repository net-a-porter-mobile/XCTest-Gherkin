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
    private var backgroundStepsExecuted = false
    
    override func defineSteps() {
        
        // Examples of defining a step with no capture groups
        step("I have a working Gherkin environment") {
            XCTAssertTrue(true)
        }

        step("Я имею рабочее окружение Gherkin") {
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

        step("этот тест не должен завершиться ([\\w0-9]*)") { (matches: [String]) in
            XCTAssertEqual(matches.first, "ошибкой")
        }

        // Example of a nested step definition
        step("This step should call another step") {
            self.step("This is another step")
        }
        
        // Example of a step that sets value in scenario context
        step("This step should set state") {
            self.test.scenarioContext["state"] = 1
        }
        
        step("This step should read state as ([0-9]+)") { (stateValue: Int) in
            XCTAssertEqual(self.test.scenarioContext["state"] as? Int, stateValue)
        }

        step("This step should not read state") {
            XCTAssertNil(self.test.scenarioContext["state"])
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

        step("I have a double ([0-9\\.]*)$") { (match: Double) in
            XCTAssertEqual(match, 1.2)
        }

        step("I have a double which looks like an int (.*)") { (match: Double) in
            XCTAssertEqual(match, 1)
        }

        step("I have a mixture of types ([0-9\\.]*) (.*)") { (d: Double, s: String) in
            XCTAssertEqual(d, 1.1)
            XCTAssertEqual(s, "hello")
        }

        step("^a substring$") {
            XCTFail("This step shouldn't match")
        }

        step("This is a substring") {
            // This step should match instead of the one above, even though the other one is defined first
        }

        step("first execute background step") {
            XCTAssertFalse(self.backgroundStepsExecuted, "Background should be executed once per scenario or example")
            self.backgroundStepsExecuted = true
        }

        step("background step should be executed") {
            XCTAssertTrue(self.backgroundStepsExecuted, "Background should be executed for each scenario or example")
            self.backgroundStepsExecuted = false
        }

        step("I'm logged in as (?!known)(\\{.+\\})") { (match: ExampleFeatures.Person) in
            XCTAssertEqual(match.name, "Alice")
        }

        if #available(iOS 11.0, OSX 10.13, *) {
            step("I'm logged in as (?<aKnownUser>Alice|Bob)") { (match: StepMatches<String>) in
                XCTAssertNotNil(match["aKnownUser"])
            }

            step("I'm logged in as a known (?<user>.+)") { (match: StepMatches<ExampleFeatures.Person>) in
                let person = match["user"]!
                XCTAssertEqual(person.name, "Alice")
            }

            step("I use the example (?<name>Alice|Bob) and the height ([0-9]+)") { (match: StepMatches<String>) in
                XCTAssertNotNil(match["name"])
                XCTAssertEqual(match["name"], match[0])
                XCTAssertEqual(match[1], "170")
            }

            step("I have two users (?<user1>.+) and (?<user2>.+)") { (match: StepMatches<ExampleFeatures.Person>) in
                XCTAssertNotNil(match["user1"])
                XCTAssertNotNil(match["user2"])
            }
        }

        step("This is unused step") {}
        
        step("I verify (.+) password( against (.+) username)?") { (matches: [String]) in
            XCTAssertEqual(matches.first, "test")
            if matches.count > 1 {
                XCTAssertEqual(matches.last, "user")
            }
        }

    }
}

final class MatchStringLiteralStepDefiner: StepDefiner {

    /// This is a literal, which if used as a regular expression will match pretty much everything. This tests that this doesn't happen :)
    static let literal = "^(.*)$"

    override func defineSteps() {
        step(exactly: MatchStringLiteralStepDefiner.literal) {
        }

        /// Explicitly define a step here which contains `literal` to sanity check that the exact matcher doesn't match against substrings.
        step(MatchStringLiteralStepDefiner.literal + " NOPE") {
            XCTFail("This step should definitely not have matched")
        }
    }
}
