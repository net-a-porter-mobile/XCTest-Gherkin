//
//  ScenarioContextTests.swift
//  XCTest-Gherkin_Tests
//
//  Created by Ilya Puchka on 16/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class ScenarioContextTests: XCTestCase {
    // Tests are numbered to ensure order of execution
    
    func test0() {
        Then("This step should not read state")
    }
    
    func test1() {
        Given("This step should set state")
        Then("This step should read state as <state>")
    }
    
    func test2() {
        Then("This step should not read state")
    }

}
