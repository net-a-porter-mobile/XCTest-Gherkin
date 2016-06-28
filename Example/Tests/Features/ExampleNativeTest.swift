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

    override func setUp() {
        super.setUp()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        self.path = bundle.resourceURL?.URLByAppendingPathComponent("NativeFeatures")
        
        XCTAssertNotNil(self.path)
        
        ColorLog.enabled = true
    }
    
}
