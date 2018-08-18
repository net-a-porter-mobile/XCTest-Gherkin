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
        
        step("I tap the (.*) button") { (matches: [String]) in
            XCTAssert(matches.count > 0, "Should have been a match")
            
            let identifier = matches.first!
            
            XCUIApplication().buttons[identifier].tap()
        }
        
    }
    
}

final class InitialScreenStepDefiner: StepDefiner {

    override func defineSteps() {

        step("I press Push Me button") {
            InitialScreenPageObject().pressPushMe()
        }

    }

}

final class InitialScreenPageObject: PageObject {

    let app = XCUIApplication()

    override func isPresented() -> Bool {
        return tryWaitFor(element: app.buttons["PushMe"], withState: "exists == true")
    }

    func pressPushMe() {
        app.buttons["PushMe"].tap()
    }
}

final class ModalScreenStepDefiner: StepDefiner {

    override func defineSteps() {

        step("I press Close Me button") {
            ModalScreenPageObject().pressCloseMe()
        }

    }

}

final class ModalScreenPageObject: PageObject {

    let app = XCUIApplication()

    override func isPresented() -> Bool {
        return tryWaitFor(element: app.buttons["CloseMe"], withState: "exists == true")
    }

    func pressCloseMe() {
        app.buttons["CloseMe"].tap()
    }
}

extension PageObject {

    func tryWaitFor(element: XCUIElement, withState state: String, waiting timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: state)
        guard predicate.evaluate(with: element) == false else { return true }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout) ==  XCTWaiter.Result.completed
        return result
    }
}
