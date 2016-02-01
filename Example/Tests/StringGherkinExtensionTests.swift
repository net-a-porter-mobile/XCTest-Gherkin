//
//  StringGherkinExtensionTests.swift
//  XCTest-Gherkin
//
//  Created by Francesco Tatullo on 27/01/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Foundation

class StringGherkinExtensionTests: XCTestCase {


    func testCamelCaseify_noSpecialChars() {
        let simpleString = "justoneword"
        XCTAssertEqual("Justoneword", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_oneSpace() {
        let simpleString = "two words"
        XCTAssertEqual("TwoWords", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_multipleSpaces() {
        let simpleString = "more than two words"
        XCTAssertEqual("MoreThanTwoWords", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_oneSpaceOneDash() {
        let simpleString = "designers a-z"
        XCTAssertEqual("DesignersAZ", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_twoSpacesTwoDashes() {
        let simpleString = "d--esigners  az"
        XCTAssertEqual("DEsignersAz", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_allCaps() {
        let simpleString = "THIS IS ALL CAPS"
        XCTAssertEqual("ThisIsAllCaps", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_home() {
        let simpleString = "home"
        XCTAssertEqual("Home", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_ShoppingBag() {
        let simpleString = "ShoppingBag"
        XCTAssertEqual("ShoppingBag", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_DesignerAZ() {
        let simpleString = "DesignerAZ"
        XCTAssertEqual("DesignerAZ", simpleString.camelCaseify)
    }
    
    func testCamelCaseify_emptyStringDoesntCrash() {
        let simpleString = ""
        XCTAssertEqual("", simpleString.camelCaseify)
    }
    
}
