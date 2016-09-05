//
//  ExampleNativeTest.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 05/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class ExampleNativeTest : NativeTestCase {
    override class func path() -> NSURL? {
        let bundle = NSBundle(forClass: self)
        return bundle.resourceURL?.URLByAppendingPathComponent("NativeFeatures/native_example.feature")
    }
    
    override func setUp() {
        super.setUp()
        print("Default setup method works before each native scenario")
        ColorLog.enabled = true
    }
    
    func testCanSpecifyRegularTestAsWell() {
        XCTAssert(true)
    }
}
