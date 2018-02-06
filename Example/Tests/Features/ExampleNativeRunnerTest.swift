//
//  ExampleNativeRunnerTest.swift
//  XCTest-Gherkin
//
//  Created by jacdevos on 2016/11/15.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

final class ExampleNativeRunnerTest: XCTestCase {

    func testNativeExampleWithFeatureRunner() {
        NativeRunner.runFeature(featureFile: "NativeFeatures/native_example.feature", testCase: self)
    }
    
    func testNativeExampleWithScenarioRunner() {
        NativeRunner.runScenario(featureFile: "NativeFeatures/native_example.feature", scenario: "This is a basic happy path example", testCase: self)
    }
}
