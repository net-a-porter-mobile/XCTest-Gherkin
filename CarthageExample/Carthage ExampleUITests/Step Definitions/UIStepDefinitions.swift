//
//  UIStepDefinitions.swift
//  Carthage ExampleUITests
//
//  Created by Kerr Marin Miller on 2018-01-30.
//  Copyright © 2018 Net-A-Porter. All rights reserved.
//

import Foundation
import XCTest
import XCTest_Gherkin

final class UIStepDefiner: StepDefiner {

    override func defineSteps() {

        step("I have launched the app") {
            XCUIApplication().launch()
        }

        step("I tap the (.*) button") { (matches: [String]) in
            XCTAssert(matches.count > 0, "Should have been a match")

            let identifier = matches.first!

            XCUIApplication().buttons[identifier].tap()
        }

    }

}
