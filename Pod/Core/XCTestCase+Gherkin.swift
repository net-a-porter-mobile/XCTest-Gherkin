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

#if canImport(XCTest_Gherkin_ObjC)
import XCTest_Gherkin_ObjC
#endif

/**
I wanted this to work with both KIFTestCase and UITestCase which meant extending
UITestCase - a subclass wouldn't work with both of them.

It's nicer code IMHO to have the state as a single associated property beacuse of the grossness of setting/getting it.
This means that anytime I want to access my extra properties I just do `state.{propertyName}`
*/
class GherkinState: NSObject, XCTestObservation {
    var test: XCTestCase?
    
    // Arbitrary user data associated with the current test scenario
    var scenarioContext: [String: MatchedStringRepresentable] = [:]
    
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
    var currentSuiteName: String = "NO TESTS RUN YET"
    
    // Store the name of the current step to help debugging output
    var currentStepName: String = "NO CURRENT STEP YET"
    
    fileprivate var missingStepsImplementations = [String]()
    
    override init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        guard let test = self.test, let (file, line) = test.state.currentStepLocation else { return }
        if filePath == file && lineNumber == line { return }

        if #available(iOS 9.0, OSX 10.11, *) {
            if automaticScreenshotsBehaviour.contains(.onFailure) {
                test.attachScreenshot()
            }
        }
        test.recordFailure(withDescription: description, inFile: file, atLine: line, expected: false)
        if let exampleLineNumber = self.currentNativeExampleLineNumber, lineNumber != exampleLineNumber {
            test.recordFailure(withDescription: description, inFile: file, atLine: exampleLineNumber, expected: false)
        }
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        testCase.scenarioContext = [:]
    }
    
    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        XCTestObservationCenter.shared.removeTestObserver(self)
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
        self.missingStepsImplementations
            .printAsTemplatedCodeForAllMissingSteps(suggestedSteps: self.suggestedSteps(forStep:))
    }
    
    func printStepDefinitions() {
        self.loadAllStepsIfNeeded()
        self.steps.printStepsDefinitions()
    }
    
    func loadAllStepsIfNeeded() {
        guard self.steps.count == 0 else { return }
        
        // Create an instance of each step definer and call it's defineSteps method
        allSubclassesOf(StepDefiner.self).forEach { subclass in
            subclass.init(test: self.test!).defineSteps()
        }

        UnusedStepsTracker.shared().setSteps(self.steps.map { String(reflecting: $0) })
        UnusedStepsTracker.shared().printUnusedSteps = { $0.printAsUnusedSteps() }

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
     Current scenario context used to share the state between steps in a single scenario.
     Note: Example values will override context values associated with the same key.
     */
    var scenarioContext: [String: MatchedStringRepresentable] {
        get { return state.scenarioContext }
        set { state.scenarioContext = newValue }
    }
    
    /**
     Run the step matching the specified expression
     */
    func Given(_ expression: String, file: String = #file, line: Int = #line) {
        self.performStep(expression, keyword: "Given", file: file, line: line)
    }
    
    /**
     Run the step matching the specified expression
     */
    func When(_ expression: String, file: String = #file, line: Int = #line) {
        self.performStep(expression, keyword: "When", file: file, line: line)
    }
    
    /**
     Run the step matching the specified expression
     */
    func Then(_ expression: String, file: String = #file, line: Int = #line) {
        self.performStep(expression, keyword: "Then", file: file, line: line)
    }
    
    /**
     Run the step matching the specified expression
     */
    func And(_ expression: String, file: String = #file, line: Int = #line) {
        self.performStep(expression, keyword: "And", file: file, line: line)
    }

    /**
     Run the step matching the specified expression
     */
    func But(_ expression: String, file: String = #file, line: Int = #line) {
        self.performStep(expression, keyword: "But", file: file, line: line)
    }
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

@available(iOS 9.0, OSX 10.11, *)
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

    fileprivate  var testName: String? {
        guard let selector = self.invocation?.selector else { return nil }
        let rawName = String(describing: selector)
        let testName = rawName.hasPrefix("test") ? String(rawName.dropFirst(4)) : rawName
        return testName
    }

    // MARK: Adding steps
    
    /**
     Adds a step to the global store of steps, but only if this expression isn't already defined with a step
    */
    func addStep(_ expression: String, options: NSRegularExpression.Options, file: String, line: Int, function: @escaping (StepMatches<String>)->()) {
        let step = Step(expression, options: options, file: file, line: line, function)
        state.steps.insert(step);
    }

    /**
     Finds and performs a step test based on expression
     */
    func performStep(_ initialExpression: String, keyword: String, file: String = #file, line: Int = #line) {
        // Get a mutable copy - if we are in an outline we might be changing this
        var expression = initialExpression

        // Make sure that we have created our steps
        self.state.loadAllStepsIfNeeded()

        var variables = scenarioContext
        // If we are in an example, transform the step to reflect the current example's value
        if let example = state.currentExample {
            variables = scenarioContext.merging(example, uniquingKeysWith: { $1 })
        }
        // For each variable go through the step expression and replace the placeholders if needed
        expression = expression.replacingExamplePlaceholders(variables)
        
        // Get the step and the matches inside it
        guard let (step, match) = self.state.gherkinStepsAndMatchesMatchingExpression(expression).first else {
            if !self.state.matchingGherkinStepExpressionFound(expression) && self.state.shouldPrintTemplateCodeForAllMissingSteps() {
                self.state.printStepDefinitions()
                self.state.printTemplatedCodeForAllMissingSteps()
                self.state.resetMissingSteps()
            }
            preconditionFailure("Failed to find a match for a step: \(expression)")
        }

        UnusedStepsTracker.shared().performedStep(String(reflecting: step))

        // If this is the first step, debug the test (scenario) name and feature as well
        if state.currentStepDepth == 0 {
            let suiteName = String(describing: type(of: self))
            if suiteName != state.currentSuiteName {
                print("Feature: \(suiteName)")
                state.currentSuiteName = suiteName
            }

            if let testName = self.testName, testName != state.currentTestName {
                print("  Scenario: \(testName.humanReadableString)")
                state.currentTestName = testName
                if state.currentExample == nil {
                    performBackground()
                }
            }
        }

        state.currentStepName = expression
        let (matches, debugDescription) = step.matches(from: match, expression: expression)

        // Debug the step name
        print("    step \(keyword) \(currentStepDepthString())\(debugDescription)  \(step.fullLocationDescription)")

        // Run the step
        XCTContext.runActivity(named: "\(keyword) \(debugDescription)  \(step.shortLocationDescription)") { (_) in
            state.currentStepDepth += 1
            state.currentStepLocation = (file, line)

            if #available(iOS 9.0, OSX 10.11, *) {
                if automaticScreenshotsBehaviour.contains(.beforeStep) {
                    attachScreenshot()
                }
            }

            step.function(matches)

            if #available(iOS 9.0, OSX 10.11, *) {
                if automaticScreenshotsBehaviour.contains(.afterStep) {
                    attachScreenshot()
                }
            }

            state.currentStepLocation = nil
            state.currentStepDepth -= 1
        }
    }
    
    /**
     Converts the current step depth into a string to use for padding
     
     - returns: A String of spaces equal to the current step depth
     */
    fileprivate func currentStepDepthString() -> String {
        return String(repeating: "  ", count: state.currentStepDepth)
    }
}

func requireNotNil<T>(_ expr: @autoclosure () -> T?, _ message: String) -> T {
    guard let value = expr() else { preconditionFailure(message) }
    return value
}

func requireToConvert<T>(_ expr: @autoclosure () -> T?, _ match: String, _ expression: String) -> T {
    return requireNotNil(expr(), "Could not convert '\(match)' to \(T.self) in '\(expression)'")
}
