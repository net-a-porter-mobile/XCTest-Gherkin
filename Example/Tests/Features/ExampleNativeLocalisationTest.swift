//
//  ExampleNativeLocalisationTest.swift
//  XCTest-Gherkin_Tests
//
//  Created by Ilya Puchka on 25/08/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

final class ExampleNativeLocalisationTest: XCTestCase {
    
    func testLocalisedNativeExampleWithFeatureRunner() {
        NativeRunner.runFeature(featureFile: "NativeFeatures/native_example_simple_localised.feature", testCase: self)
    }
    
}
