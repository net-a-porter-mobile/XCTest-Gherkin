//
//  Example.swift
//  whats-new
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation
import ObjectiveC

import XCTest

open class NativeTestCase: XCGNativeInitializer {

    /// Overrides XCGNativeInitializer processFeatures to create the necessary
    /// test classes and methods. There is no reason to call this method directly.
    override open class func processFeatures() {
        // We don't want to process any features for this class, all the features
        // processed should be for subclasses of this class.
        if self == NativeTestCase.self {
            return
        }
        // Register all the scenario test methods for defined features
        for feature in self.features() {
            feature.scenarios.forEach(self.registerTestMethod)
        }
    }
    
    // MARK: Config and properties
    
    // if you want to subclass this class without implementing any scenarios
    // you can use this flag to skip path check
    class open func shouldForcePathCheck() -> Bool {
        return true
    }
    
    class open func path() -> URL? {
        return nil
    }
    
    static var _features: [NativeFeature]?
    class func features() -> [NativeFeature] {
        if let features = _features {
            return features
        }
        
        guard let path = self.path() else {
            if self.shouldForcePathCheck() {
                assertionFailure("You must set the path for this test to run")
            }
            return []
        }
        
        guard let features = NativeFeatureParser(path: path).parsedFeatures() else {
            assertionFailure("Could not retrieve features from the path '\(path)'")
            return []
        }
        
        return features
    }
    
    // MARK: setUp and tearDown
    
    open override func setUp() {
        super.setUp()
        self.state.loadAllStepsIfNeeded()
    }
    
    // Displays all the missing steps accumulated during performing scenarios in this TestCase
    override open class func tearDown() {
        super.tearDown()
        if self.state.shouldPrintTemplateCodeForAllMissingSteps() {
            self.state.printStepDefinitions()
            self.state.printTemplatedCodeForAllMissingSteps()
            self.state.resetMissingSteps()
        }
    }
    
    // MARK: Test template method
    
    func featureScenarioTest() {
        guard let (feature, scenario) = type(of: self).featureScenarioData(self.invocation!.selector) else {
            return
        }
        perform(scenario: scenario, from: feature)
    }
    
    // MARK: Auxiliary

    class func featureScenarioData(_ forSelector: Selector) -> (NativeFeature, NativeScenario)? {
        for feature in self.features() {
            if let scenario = feature.scenarios.filter({ $0.selectorString == NSStringFromSelector(forSelector) }).first {
                return (feature, scenario)
            }
        }
        return nil
    }
    
    class func registerTestMethod(forScenario scenario: NativeScenario) {
        let selector = sel_registerName(scenario.selectorCString)
        let method = class_getInstanceMethod(self, #selector(featureScenarioTest))
        let success = class_addMethod(self, selector, method_getImplementation(method!), method_getTypeEncoding(method!))
        assert(success, "Could not swizzle feature test method!")
    }
    
}

extension XCTestCase {
    func perform(scenario: NativeScenario, from feature: NativeFeature) {
        let allScenarioStepsDefined = scenario.stepDescriptions.map(state.matchingGherkinStepExpressionFound).reduce(true) { $0 && $1 }
        var allFeatureBackgroundStepsDefined = true
        
        if let defined = feature.background?.stepDescriptions.map(state.matchingGherkinStepExpressionFound).reduce(true, { $0 && $1 }) {
            allFeatureBackgroundStepsDefined = defined
        }
        
        guard allScenarioStepsDefined && allFeatureBackgroundStepsDefined else {
            XCTFail("Some step definitions not found for the scenario: \(scenario.scenarioDescription)")
            return
        }
        
        if let background = feature.background {
            background.stepDescriptions.forEach(self.performStep)
        }
        scenario.stepDescriptions.forEach(self.performStep)
    }
}
