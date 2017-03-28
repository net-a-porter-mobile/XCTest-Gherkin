//
//  UITestStepDefinitions.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 6/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

import XCTest
import XCTest_Gherkin

final class UIStepDefiner: StepDefiner {
    
    override func defineSteps() {
        
        step("I have launched the app") {
            XCUIApplication().launch()
        }
        
        step("I tap the (.*) button") { (matches:[String]) in
            XCTAssert(matches.count > 0, "Should have been a match")
            
            let identifier = matches.first!
            
            XCUIApplication().buttons[identifier].tap()
        }
        
    }
    
}
