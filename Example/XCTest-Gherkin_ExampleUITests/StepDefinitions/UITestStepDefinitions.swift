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
            
            XCUIApplication().buttons[identifier].firstMatch.tap()
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

    private let app = XCUIApplication()

    class override var name: String {
        return "Initial Screen"
    }
    
    override func isPresented() -> Bool {
        return tryWaitFor(element: app.buttons["PushMe"].firstMatch, withState: .exists)
    }

    func pressPushMe() {
        app.buttons["PushMe"].firstMatch.tap()
    }
}

final class ModalScreenStepDefiner: StepDefiner {

    override func defineSteps() {

        step("I press Close Me button") {
            ModalScreen().pressCloseMe()
        }
    }
}

final class ModalScreen: PageObject {

    private let app = XCUIApplication()

    override func isPresented() -> Bool {
        return tryWaitFor(element: app.buttons["CloseMe"].firstMatch, withState: .exists)
    }

    func pressCloseMe() {
        app.buttons["CloseMe"].firstMatch.tap()
    }
}

extension PageObject {

    func tryWaitFor(element: XCUIElement, withState state: String, waiting timeout: TimeInterval = 5.0) -> Bool {
        let predicate = NSPredicate(format: state)
        guard predicate.evaluate(with: element) == false else { return true }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
        return result
    }
}

extension String {

    fileprivate static let exists = "exists == true"
}
