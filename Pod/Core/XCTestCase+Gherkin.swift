//
//  File.swift
//  whats-new
//
//  Created by Sam Dean on 26/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation
import XCTest
import WebKit

/**
I wanted this to work with both KIFTestCase and UITestCase which meant extending
UITestCase - a subclass wouldn't work with both of them.

It's nicer code IMHO to have the state as a single associated property beacuse of the grossness of setting/getting it.
This means that anytime I want to access my extra properties I just do `state.{propertyName}`
*/
class GherkinState: NSObject, XCTestObservation {
    var test: XCTestCase?
    
    // The list of all steps the system knows about
    var steps = Set<Step>()
    
    // Used to track step nesting i.e. steps calling out to other steps
    var currentStepDepth: Int = 0
    
    // file and line from where currently executed step was invoked
    var currentStepLocation: (file: String, line: Int)!

    // When we are in an Outline block, this defines the examples to loop over
    var examples: [Example]?
    
    // The current example the Outline is running over
    var currentExample: Example?

    // currently executed example line when running test from feature file
    var currentNativeExampleLineNumber: Int?

    // Store the name of the current test to help debugging output
    var currentTestName: String = "NO TESTS RUN YET"
    
    // Store the name of the current step to help debugging output
    var currentStepName: String = "NO CURRENT STEP YET"
    
    fileprivate var missingStepsImplementations = [String]()
    
    override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    deinit {
        XCTestObservationCenter.shared.removeTestObserver(self)
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        guard let test = self.test, let (file, line) = test.state.currentStepLocation else { return }
        if filePath == file && lineNumber == line { return }

        if automaticScreenshotsBehaviour.contains(.onFailure) {
            test.attachScreenshot()
        }
        test.recordFailure(withDescription: description, inFile: file, atLine: line, expected: false)
        if let exampleLineNumber = self.currentNativeExampleLineNumber, lineNumber != exampleLineNumber {
            test.recordFailure(withDescription: description, inFile: file, atLine: exampleLineNumber, expected: false)
        }
    }

    func gherkinStepsAndMatchesMatchingExpression(_ expression: String) -> [(step: Step, match: NSTextCheckingResult)] {
        let range = NSMakeRange(0, expression.count)

        return self.steps.compactMap { step in
            step.regex.firstMatch(in: expression, options: [], range: range).map { (step: step, match: $0) }
        }
    }
    
    func gherkinStepsMatchingExpression(_ expression: String) -> [Step] {
        return self.gherkinStepsAndMatchesMatchingExpression(expression).map { $0.step }
    }
    
    // TODO: This needs to be refactored since function has a side effect (appends to missingStepsImplementations)
    func matchingGherkinStepExpressionFound(_ expression: String) -> Bool {
        let matches = self.gherkinStepsMatchingExpression(expression)
        switch matches.count {
        case 0:
            print("Step definition not found for '\(expression)'")
            self.missingStepsImplementations.append(expression)
        case 1:
            //no issues, so proceed
            return true
        default:
            matches.forEach { NSLog("Matching step : \(String(reflecting: $0))") }
            print("Multiple step definitions found for : '\(expression)'")
        }
        return false
    }
    
    func shouldPrintTemplateCodeForAllMissingSteps() -> Bool {
        return self.missingStepsImplementations.count > 0
    }
    
    func resetMissingSteps() {
        self.missingStepsImplementations = []
    }
    
    func printTemplatedCodeForAllMissingSteps() {
        print("Copy paste these steps in a StepDefiner subclass:")
        print("-------------")
        self.missingStepsImplementations.forEach({
            print("step(\"\($0)"+"\") {XCTAssertTrue(true)}")
            let suggestedSteps = self.suggestedSteps(forStep: $0)
            if !suggestedSteps.isEmpty {
                print("-------------\nOr maybe you meant one of these steps:\n-------------")
                print(suggestedSteps.map { String(reflecting: $0) }.joined(separator: "\n"))
            }
        })
        print("-------------")
    }
    
    func printStepDefinitions() {
        self.loadAllStepsIfNeeded()
        print("-------------")
        print("Defined steps")
        print("-------------")
        print(self.steps.map { String(reflecting: $0) }.sorted { $0.lowercased() < $1.lowercased() }.joined(separator: "\n"))
        print("-------------")
    }
    
    func loadAllStepsIfNeeded() {
        guard self.steps.count == 0 else { return }
        
        // Create an instance of each step definer and call it's defineSteps method
        allSubclassesOf(StepDefiner.self).forEach { subclass in
            subclass.init(test: self.test!).defineSteps()
        }
        
        precondition(self.steps.count > 0, "No steps have been defined - there must be at least one subclass of StepDefiner which defines at least one step!")
    }
}

/**
 Add Gherkin methods to XCTestCase
*/
public extension XCTestCase {
    
    fileprivate struct AssociatedKeys {
        static var State = "AssociatedStateKey"
    }
    
    internal var state: GherkinState {
        type(of: self).state.test = self
        return type(of: self).state
    }
    
    internal static var state: GherkinState {
        get {
            guard let s = objc_getAssociatedObject(self, &AssociatedKeys.State) else {
                let initialState = GherkinState()
                objc_setAssociatedObject(self, &AssociatedKeys.State, initialState, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return initialState
            }

            return s as! GherkinState
        }
    }
    
    /**
     Run the step matching the specified expression
     */
    func Given(_ expression: String, file: String = #file, line: Int = #line) { self.performStep(expression, file: file, line: line) }
    
    /**
     Run the step matching the specified expression
     */
    func When(_ expression: String, file: String = #file, line: Int = #line) { self.performStep(expression, file: file, line: line) }
    
    /**
     Run the step matching the specified expression
     */
    func Then(_ expression: String, file: String = #file, line: Int = #line) { self.performStep(expression, file: file, line: line) }
    
    /**
     Run the step matching the specified expression
     */
    func And(_ expression: String, file: String = #file, line: Int = #line) { self.performStep(expression, file: file, line: line) }
    
}

private var automaticScreenshotsBehaviour: AutomaticScreenshotsBehaviour = .none
private var automaticScreenshotsQuality: XCTAttachment.ImageQuality = .medium
private var automaticScreenshotsLifetime: XCTAttachment.Lifetime = .deleteOnSuccess

public struct AutomaticScreenshotsBehaviour: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let onFailure     = AutomaticScreenshotsBehaviour(rawValue: 1 << 0)
    public static let beforeStep    = AutomaticScreenshotsBehaviour(rawValue: 1 << 1)
    public static let afterStep     = AutomaticScreenshotsBehaviour(rawValue: 1 << 2)
    public static let none: AutomaticScreenshotsBehaviour = []
    public static let all: AutomaticScreenshotsBehaviour = [.onFailure, .beforeStep, .afterStep]
}

extension XCTestCase {

    /// Set behaviour for automatic screenshots (default is `.none`), their quality (default is `.medium`) and lifetime (default is `.deleteOnSuccess`)
    public static func setAutomaticScreenshotsBehaviour(_ behaviour: AutomaticScreenshotsBehaviour,
                                                        quality: XCTAttachment.ImageQuality = .medium,
                                                        lifetime: XCTAttachment.Lifetime = .deleteOnSuccess) {
        automaticScreenshotsBehaviour = behaviour
        automaticScreenshotsQuality = quality
        automaticScreenshotsLifetime = lifetime
    }

    func attachScreenshot() {
        // if tests have no host app there is no point in making screenshots
        guard Bundle.main.bundlePath.hasSuffix(".app") else { return }

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot, quality: automaticScreenshotsQuality)
        attachment.lifetime = automaticScreenshotsLifetime
        add(attachment)
    }
}

/**
 Put our package methods into this extension
*/
extension XCTestCase {
    // MARK: Adding steps
    
    /**
     Adds a step to the global store of steps, but only if this expression isn't already defined with a step
    */
    func addStep(_ expression: String, file: String, line: Int, _ function: @escaping ([String])->()) {
        let step = Step(expression, file: file, line: line, function)
        state.steps.insert(step);
    }
    
    /**
     Finds and performs a step test based on expression
     */
    func performStep(_ initialExpression: String, file: String = #file, line: Int = #line) {

        func perform(expression: String) {
            
            // Get a mutable copy - if we are in an outline we might be changing this
            var expression = initialExpression
            
            // Make sure that we have created our steps
            self.state.loadAllStepsIfNeeded()
            
            // If we are in an example, transform the step to reflect the current example's value
            if let example = state.currentExample {
                // For each field in the example, go through the step expression and replace the placeholders if needed
                expression = example.reduce(expression, {
                    $0.replacingOccurrences(of: "<\($1.key)>", with: String(describing: $1.value))
                })
            }
            
            // Get the step and the matches inside it
            guard let (step, match) = self.state.gherkinStepsAndMatchesMatchingExpression(expression).first else {
                if !self.state.matchingGherkinStepExpressionFound(expression) && self.state.shouldPrintTemplateCodeForAllMissingSteps() {
                    self.state.printStepDefinitions()
                    self.state.printTemplatedCodeForAllMissingSteps()
                    self.state.resetMissingSteps()
                }
                preconditionFailure("Failed to find a match for a step: \(expression)")
            }
            
            // Covert them to strings to pass back into the step function
            // TODO: This should really only need to be a map function :(
            var matchStrings = Array<String>()
            for i in 1..<match.numberOfRanges {
                let range = match.range(at: i)
                let string = range.location != NSNotFound ? (expression as NSString).substring(with: range) : ""
                matchStrings.append(string)
            }
            
            // If this the first step, debug the test name as well
            if state.currentStepDepth == 0 {
                let rawName = String(describing: self.invocation!.selector)
                let testName = rawName.hasPrefix("test") ? (rawName as NSString).substring(from: 4) : rawName
                if testName != state.currentTestName {
                    NSLog("steps from \(testName.humanReadableString)")
                    state.currentTestName = testName
                }
            }
            
            // Debug the step name
            NSLog("step \(currentStepDepthString())\(expression)")
            state.currentStepName = expression
            
            // Run the step
            state.currentStepDepth += 1
            state.currentStepLocation = (file, line)
            if automaticScreenshotsBehaviour.contains(.beforeStep) {
                attachScreenshot()
            }
            step.function(matchStrings)
            if automaticScreenshotsBehaviour.contains(.afterStep) {
                attachScreenshot()
            }
            state.currentStepLocation = nil
            state.currentStepDepth -= 1
        }
        
        XCTContext.runActivity(named: initialExpression) { (_) in
            perform(expression: initialExpression)
        }
    }
    
    /**
     Converts the current step depth into a string to use for padding
     
     - returns: A String of spaces equal to the current step depth
     */
    fileprivate func currentStepDepthString() -> String {
        return repeatElement(" ", count: state.currentStepDepth).joined(separator: "")
    }
}

func requireNotNil<T>(_ expr: @autoclosure () -> T?, _ message: String) -> T {
    guard let value = expr() else { preconditionFailure(message) }
    return value
}
