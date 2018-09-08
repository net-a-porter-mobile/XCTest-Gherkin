//
//  NativeScenarioTest.swift
//  XCTest-Gherkin
//
//  Created by Kerr Marin Miller on 06/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import XCTest_Gherkin

final class NativeScenarioTest: XCTestCase {
    
    func testNativeScenarioSelectorString() {
        let scenario = NativeScenario("This is a test", steps: [])
        XCTAssertEqual(scenario.selectorString, "testThisIsATest")
    }
}
