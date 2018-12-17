//
//  BackgroundTests.swift
//  XCTest-Gherkin_Tests
//
//  Created by Ilya Puchka on 01/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class BackgroundTests: XCTestCase {
    
    func Background() {
        Given("first execute background step")
    }

    func testBackgroundInSimpleScenario() {
        Then("background step should be executed")
    }

    func testBackgroundInScenarioOutline() {
        Examples([""], ["1"], ["2"])

        Outline {
            Then("background step should be executed")
        }
    }

}
