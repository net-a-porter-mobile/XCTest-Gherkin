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
    private var answer = 0
    
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
        }

        step("This is unused step") {}

        step("I know the following persons: (.+)") { (match: DataTable<[ExampleFeatures.Person]>) in
            XCTAssertTrue(match.values[0].name == "Alice" || match.values[1].name == "Bob")
        }

        step("I know the following persons by name: (.+)") { (match: DataTable<[String: ExampleFeatures.Person]>) in
            XCTAssertTrue(match.values["Alice"]?.name == "Alice" || match.values["Bob"]?.name == "Bob")
        }

        step("I add the following numbers: (.+)") { (match: DataTable<[Int]>) in
            self.answer = match.values.reduce(self.answer, +)
        }

        step("I add the following letters: (.+)") { (match: DataTable<[String: Int]>) in
            self.answer = match.values.values.reduce(self.answer, +)
        }

        step("I end up with (\\d+)") { (match: Int) in
            XCTAssertEqual(self.answer, match)
            self.answer = 0
        }

        step("I have the following array: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(match.values, [1, 2, 3])
        }

        step("I have the following array of arrays: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(match.values, [[1, 4], [2, 5], [3, 6]])
        }

        step("I have the following hash maps: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(
                match.values,
                [
                    [ "firstName": "Annie M.G.","lastName": "Schmidt",  "birthDate": "1911-03-20" ],
                    [ "firstName": "Roald",     "lastName": "Dahl",     "birthDate": "1916-09-13" ],
                    [ "firstName": "Astrid",    "lastName": "Lindgren", "birthDate": "1907-11-14" ]
                ]
            )
        }

        step("I have the following hash map: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(
                match.values,
                [
                    "KMSY": "Louis Armstrong New Orleans International Airport",
                    "KSFO": "San Francisco International Airport",
                    "KSEA": "Seattle–Tacoma International Airport",
                    "KJFK": "John F. Kennedy International Airport"
                ]
            )
        }

        step("I have the following hash map list: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(
                match.values,
                [
                    "KMSY": [29.993333, -90.258056],
                    "KSFO": [37.618889, -122.375000],
                    "KSEA": [47.448889, -122.309444],
                    "KJFK": [40.639722, -73.778889]
                ]
            )
        }

        step("I have the following hash map hash: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(
                match.values,
                [
                    "KMSY": [ "lat": 29.993333, "lon": -90.258056 ],
                    "KSFO": [ "lat": 37.618889, "lon": -122.375000 ],
                    "KSEA": [ "lat": 47.448889, "lon": -122.309444 ],
                    "KJFK": [ "lat": 40.639722, "lon": -73.778889 ]
                ]
            )
        }

        step("I have the following persons: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(
                match.values,
                [
                    NativeDataTableTest.Person(name: "Alice", age: "20", height: 170, fulltime: true),
                    NativeDataTableTest.Person(name: "Bob", age: "21", height: 171, fulltime: false)
                ]
            )
        }

        step("I have the following persons by id: (.+)") { (match: NativeDataTable) in
            XCTAssertEqual(
                match.values,
                [
                    1: NativeDataTableTest.Person(name: "Alice", age: "20", height: 170, fulltime: true),
                    2: NativeDataTableTest.Person(name: "Bob", age: "21", height: 171, fulltime: false)
                ]
            )
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
