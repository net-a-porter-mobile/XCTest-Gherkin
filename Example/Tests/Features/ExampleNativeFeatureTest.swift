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
    override class func path() -> NSURL? {
        let bundle = NSBundle(forClass: self)
        return  bundle.resourceURL?.URLByAppendingPathComponent("NativeFeatures/native_example.feature")
    }
}

class RunMultipleFeatureFilesTest: NativeTestCase {
    override class func path() -> NSURL? {
        let bundle = NSBundle(forClass: self)
        return bundle.resourceURL?.URLByAppendingPathComponent("NativeFeatures/")
    }
}
