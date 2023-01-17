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

    public class func runScenario(featureFile: String,
                                  scenario: String?,
                                  testCase: XCTestCase,
                                  mapStepDefiner: StepDefiner.Type? = nil) {
        testCase.state.loadAllStepsIfNeeded(mapStepDefiner)

        var bundle = Bundle(for: type(of: testCase))
        #if SWIFT_PACKAGE
            bundle = Bundle.module
        #endif
        let path = bundle.resourceURL?.appendingPathComponent(featureFile)
        let featureFilePath = requireNotNil(path, "Path could not be built for feature file: \(featureFile)")

        let features = loadFeatures(path: featureFilePath)
        
        for feature in features {
            let scenarios: [NativeScenario]
            if let scenario = scenario {
                scenarios = feature.scenarios.filter { $0.name == scenario }
            } else {
                scenarios = feature.scenarios
            }
            
            precondition(!scenarios.isEmpty, "No scenario found with name: \(scenario)")

            for scenario in scenarios {
                testCase.perform(scenario: scenario, from: feature)
            }
        }
    }
    
    public class func runFeature(featureFile: String, testCase: XCTestCase) {
        NativeRunner.runScenario(featureFile: featureFile, scenario: nil, testCase: testCase)
    }
    
    private class func loadFeatures(path: URL) -> [NativeFeature] {
        let features = requireNotNil(NativeFeatureParser(path: path).parsedFeatures(),
                                     "Could not retrieve features from the path '\(path)'")
        return features
    }
}
