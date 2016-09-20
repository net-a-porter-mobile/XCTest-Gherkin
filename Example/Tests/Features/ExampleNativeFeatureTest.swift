//
//  ExampleNativeFeatureTest.swift
//  XCTest-Gherkin
//
//  Created by Marcin Raburski on 30/06/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class RunSingleFeatureFileTest: NativeTestCase {
    override class func path() -> URL? {
        let bundle = Bundle(for: self)
        return  bundle.resourceURL?.appendingPathComponent("NativeFeatures/native_example_simple.feature")
    }
}

class RunMultipleFeatureFilesTest: NativeTestCase {
    override class func path() -> URL? {
        let bundle = Bundle(for: self)
        return bundle.resourceURL?.appendingPathComponent("NativeFeatures/")
    }
}
