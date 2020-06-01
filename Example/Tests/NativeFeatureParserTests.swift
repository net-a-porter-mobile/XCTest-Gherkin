//
//  NativeFeatureParserTests.swift
//  XCTest-Gherkin_Tests
//
//  Created by Ilya Puchka on 01/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Foundation
@testable import XCTest_Gherkin

class NativeFeatureParserTests: XCTestCase {

    func testFeatureParsing() {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.resourceURL!.appendingPathComponent("NativeFeatures/native_example.feature")

        let feature = NativeFeatureParser(path: path).parsedFeatures()?.first

        XCTAssertEqual(feature?.name, "Feature file parsing")
        XCTAssertEqual(
            feature?.featureDescription,
            """
            This feature describes usage of basic Gherkin syntax
            For example, features can have descriptions
            """
        )

        let background = feature?.background

        XCTAssertEqual(background?.name, "")
        XCTAssertEqual(background?.scenarioDescription, "Backgrounds also can have descriptions")
        XCTAssertEqual(
            background?.stepDescriptions.map { $0.expression },
            [
                "I have duplicate steps at the start of every scenario",
                "I should move these steps to the background section"
            ])

        let scenarios = feature?.scenarios

        XCTAssertEqual(scenarios?.count, 4)
        XCTAssertEqual(scenarios?[0].name, "This is a basic happy path example")
        XCTAssertEqual(scenarios?[0].scenarioDescription, "Scenario can have a discription too")

        XCTAssertEqual(
            scenarios?[0].stepDescriptions.map { $0.expression },
            [
                "I have a working Gherkin environment",
                "This test should not fail"
            ])
        
        XCTAssertEqual(scenarios?[2].name, "Demonstrate that examples work")
        XCTAssertEqual(
            scenarios?[2].scenarioDescription,
            """
            Even scenario outline can have description
            Description can be multiline
            """
        )

        XCTAssertEqual(
            scenarios?[2].stepDescriptions.map { $0.expression },
            [
                "I use the example name <name>",
                "The age should be <age>"
            ])

        XCTAssertEqual(scenarios?[2].name, "Demonstrate that examples work")
        XCTAssertEqual(
            scenarios?[2].scenarioDescription,
            """
            Even scenario outline can have description
            Description can be multiline
            """
        )

        XCTAssertEqual(
            (scenarios?[2] as? NativeScenarioOutline)?.examples.map { $0.pairs },
            [
                ["name": "Alice", "age": "20"],
                ["name": "Bob", "age": "20"]
            ])

        XCTAssertEqual(scenarios?[0].tags, ["iOS1","iOS2","iOS3"])
        XCTAssertEqual(scenarios?[1].tags, ["iOS1"])
        XCTAssertEqual(scenarios?[2].tags, ["iOS1","iOS5"])

    }

}
