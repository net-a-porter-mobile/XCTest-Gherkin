//
//  ExampleNativeOrderTest.swift
//  XCTest-Gherkin
//
//  Created by Kerr Marin Miller on 04/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class ExampleNativeOrderTest: NativeTestCase {
    override class func path() -> URL? {
        let bundle = Bundle(for: self)
        return bundle.resourceURL?.appendingPathComponent("NativeFeatures/native_example_order.feature")
    }
}

