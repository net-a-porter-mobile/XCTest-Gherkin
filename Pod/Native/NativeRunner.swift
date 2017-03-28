//
//  NativeRunner.swift
//  Pods
//
//  Created by jacdevos on 2016/11/15.
//
//

import Foundation
import XCTest

//Gives us the ability to run features or scenarios directly by specifying file and name
open class NativeRunner {
    
    public class func runScenario(featureFile: String, scenario: String?, testCase: XCTestCase) {
        testCase.state.loadAllStepsIfNeeded()

        guard let path = (Bundle(for: type(of: testCase)).resourceURL?.appendingPathComponent(featureFile)) else {
            XCTFail("Path could not be built for feature file: \(featureFile)")
            return
        }
        
        let features = loadFeatures(path: path)
        
        for feature in features {
            let scenarios = feature.scenarios.filter {
                scenario == nil || $0.scenarioDescription.hasPrefix(scenario!)
            }
            
            if scenarios.count < 1 {
                XCTFail("No scenario found with name: \(scenario ?? "<no scenario provided>")")
            }
            
            for scenario in scenarios {
                let allScenarioStepsDefined = scenario.stepDescriptions.map(testCase.state.matchingGherkinStepExpressionFound).reduce(true) { $0 && $1 }
                var allFeatureBackgroundStepsDefined = true
                
                if let defined = feature.background?.stepDescriptions.map(testCase.state.matchingGherkinStepExpressionFound).reduce(true, { $0 && $1 }) {
                    allFeatureBackgroundStepsDefined = defined
                }
                
                guard allScenarioStepsDefined && allFeatureBackgroundStepsDefined else {
                    XCTFail("Some step definitions not found for the scenario: \(scenario.scenarioDescription)")
                    return
                }
                
                if let background = feature.background {
                    background.stepDescriptions.forEach(testCase.performStep)
                }
                scenario.stepDescriptions.forEach(testCase.performStep)
            }
        }
    }
    
    
    public class func runFeature(featureFile: String, testCase: XCTestCase) {
        NativeRunner.runScenario(featureFile: featureFile, scenario: nil, testCase: testCase)
    }

    
    private class func loadFeatures(path : URL) -> [NativeFeature] {
        guard let features = NativeFeatureParser(path: path).parsedFeatures() else {
            assertionFailure("Could not retrieve features from the path '\(path)'")
            return []
        }
        
        return features
    }

}
