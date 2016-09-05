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

public class NativeTestCase : XCTestCase {
    
    class public func path() -> NSURL? {
        return nil
    }
    
    internal var feature: NativeFeature?
    internal var scenario: NativeScenario?
    
    func featureScenarioTest() {
        if self.state.stepChecker.shouldPrintTemplateCodeForAllMissingSteps() {
            return
        }
        
        if let background = self.feature?.background {
            background.stepDescriptions.forEach { self.performStep($0) }
        }
        if let scenario = self.scenario {
            scenario.stepDescriptions.forEach { self.performStep($0) }
        }
    }
    
    override public class func defaultTestSuite() -> XCTestSuite {
        let testSuite = XCTestSuite(name: NSStringFromClass(self))
        
        // This class must by subclassed in order to specify the path
        guard self != NativeTestCase.self else {
            return testSuite
        }
        
        guard let path = self.path() else {
            assertionFailure("You must set the path for this test to run")
            return testSuite
        }
        
        guard let features = NativeFeatureParser(path: path).parsedFeatures() else {
            assertionFailure("Could not retrieve features from the path '\(path)'")
            return testSuite
        }
        
        for feature in features {
            for scenario in feature.scenarios {
                
                let selector = sel_registerName(scenario.selectorCString)
                let method = class_getInstanceMethod(NativeTestCase.classForCoder(), #selector(featureScenarioTest))
                let success = class_addMethod(NativeTestCase.classForCoder(), selector, method_getImplementation(method), method_getTypeEncoding(method))
                
                let testCase = super.init(selector: selector) as! NativeTestCase
                
                testCase.feature = feature
                testCase.scenario = scenario
            
                testSuite.addTest(testCase)
            }

        }
        
        return testSuite
    }
    
}
