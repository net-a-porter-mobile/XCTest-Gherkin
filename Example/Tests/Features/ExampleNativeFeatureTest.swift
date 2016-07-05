//
//  ExampleNativeFeatureTest.swift
//  XCTest-Gherkin
//
//  Created by Marcin Raburski on 30/06/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

class ExampleNativeFeatureTest: NativeTestCase {

    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        
        // In case you want to use only one feature file instead of the whole folder
        // Just provide the URL to the file
        self.path = bundle.resourceURL?.URLByAppendingPathComponent("NativeFeatures/native_example.feature")
        
        XCTAssertNotNil(self.path)
    }
}
