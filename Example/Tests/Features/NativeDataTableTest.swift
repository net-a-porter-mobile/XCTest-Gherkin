//
//  NativeDataTableTest.swift
//  XCTest-Gherkin_Tests
//
//  Created by Ilya Puchka on 03/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import XCTest_Gherkin

final class NativeDataTableTest: NativeTestCase {

    struct Person: CodableMatchedStringRepresentable, Equatable {
        let name: String
        let age: String
        let height: Int
        let fulltime: Bool
    }

    override class func path() -> URL? {
        let bundle = Bundle(for: self)
        return bundle.resourceURL?.appendingPathComponent("NativeFeatures/native_data_table.feature")
    }

    override func setUp() {
        super.setUp()
        print("Default setup method works before each native scenario")
    }
}
