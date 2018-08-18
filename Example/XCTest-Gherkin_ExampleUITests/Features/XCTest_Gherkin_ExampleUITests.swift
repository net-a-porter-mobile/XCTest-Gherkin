//
//  XCTest_Gherkin_ExampleUITests.swift
//  XCTest-Gherkin_ExampleUITests
//
//  Created by Sam Dean on 6/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class XCTest_Gherkin_ExampleUITests: XCTestCase {
    
    func testWorksWithUITests() {
        Given("I have launched the app")
        When("I tap the PushMe button")
    }

    func testPresentModal() {
        self.continueAfterFailure = false

        Given("I have launched the app")
        Then("I see Initial Screen")

        When("I press Push Me button")
        Then("I see Modal Screen")

        When("I press Close Me button")
        Then("I see Initial Screen")
    }

}
