//
//  NativeScenarioTest.swift
//  XCTest-Gherkin
//
//  Created by Kerr Marin Miller on 06/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import XCTest_Gherkin

class NativeScenarioTest: XCTestCase {
    
    func testNativeScenarioSelectorString() {
        let scenario = NativeScenario("This is a test", steps: [], index: 1)
        XCTAssertEqual(scenario.selectorString, "test001ThisIsATest")
        
        let scenario10 = NativeScenario("This is a test", steps: [], index: 11)
        XCTAssertEqual(scenario10.selectorString, "test011ThisIsATest")
        
        let scenario100 = NativeScenario("This is a test", steps: [], index: 111)
        XCTAssertEqual(scenario100.selectorString, "test111ThisIsATest")
    }
}
