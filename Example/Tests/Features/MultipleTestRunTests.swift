//
//  MultipleTestRunTests.swift
//  XCTest-Gherkin_Tests
//
//  Created by Sam Dean on 13/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import XCTest_Gherkin

/// This is a test to make sure that a step definer isn't just pointing at a random test case (usually the first run test)
/// but is instead always pointing at the _current_ test case :)
///
/// In tearDown we remove the instance parameter so this test instance is invalid from now on.
///
/// If we run two identical tests they should (obviously) pass. However, if the step definer is still pointing at the first test
/// when the second test is run then it will fail.
final class MultipleTestRunFeature: XCTestCase {
    fileprivate var instanceParameter: String? = "Hello"

    override func tearDown() {
        self.instanceParameter = nil
    }

    func testFirst() {
        Then("the test should contain it's own instance of instanceParameter")
    }

    func testSecond() {
        Then("the test should contain it's own instance of instanceParameter")
    }
}

final class LoginSteps: StepDefiner {

    private var feature: MultipleTestRunFeature {
        return test as! MultipleTestRunFeature
    }

    override func defineSteps() {
        step("the test should contain it's own instance of instanceParameter") {
            XCTAssertNotNil(self.feature.instanceParameter)
        }
    }
}
