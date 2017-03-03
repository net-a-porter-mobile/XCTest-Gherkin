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
    override class func path() -> URL? {
        let bundle = Bundle(for: self)
        return bundle.resourceURL?.appendingPathComponent("NativeFeatures/native_example.feature")
    }
    
    override func setUp() {
        super.setUp()
        print("Default setup method works before each native scenario")
    }
}
