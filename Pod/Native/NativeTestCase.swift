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
        
        guard let features = self.featuresForPath(path) else {
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
    
    class func featuresForPath(path: NSURL) -> [NativeFeature]? {
        let manager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = ObjCBool(false)
        guard manager.fileExistsAtPath(path.path!, isDirectory: &isDirectory) else {
            XCTFail("The path doesn not exist '\(path)'")
            return nil
        }
        
        if isDirectory {
            // Get the files from that folder
            if let files = manager.enumeratorAtURL(path, includingPropertiesForKeys: nil, options: [], errorHandler: nil) {
                return self.parseFeatureFiles(files)
            } else {
                XCTFail("Could not open the path '\(path)'")
            }
            
        } else {
            if let feature = self.parseFeatureFile(path) {
                return [feature]
            }
        }
        return nil
    }
    
    class func parseFeatureFiles(files: NSDirectoryEnumerator) -> [NativeFeature] {
        return files.map({ return self.parseFeatureFile($0 as! NSURL)!})
    }
    
    class func parseFeatureFile(file: NSURL) -> NativeFeature? {
        guard let feature = NativeFeature(contentsOfURL:file, stepChecker:GherkinStepsChecker()) else {
            XCTFail("Could not parse feature at URL \(file.description)")
            return nil
        }
        return feature
    }
}
