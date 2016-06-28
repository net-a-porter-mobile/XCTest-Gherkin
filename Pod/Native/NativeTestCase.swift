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
    
    public var path:NSURL?
    
    /*
     The Gherkin Steps Checker checks if all Gherkin steps have been implemented in a StepDefiner subclass.
     */
    let stepChecker = GherkinStepsChecker()

    /**
     This method will dynamically create tests from the files in the folder specified by setting the path property on this instance.
    */
    func testRunNativeTests() {
        // If this hasn't been subclassed, just return
        guard self.dynamicType != NativeTestCase.self else { return }
        
        // Sanity
        guard let path = self.path else {
            XCTAssertNotNil(self.path, "You must set the path for this test to run")
            return
        }
        
        // Get the files from that folder
        guard let files = NSFileManager.defaultManager().enumeratorAtURL(path, includingPropertiesForKeys: nil, options: [], errorHandler: nil) else {
            XCTFail("Could not open the path '\(path)'")
            return
        }
        
        parseFeatureFiles(files)
    }
    
    func parseFeatureFiles(files: NSDirectoryEnumerator){
        var features = [NativeFeature]()
        files.forEach {
            if let feature = NativeFeature(contentsOfURL:($0 as! NSURL), stepChecker:stepChecker){
                features.append(feature)
            } else {
                XCTFail("Could not parse feature at URL \(($0 as! NSURL).description)")
            }
        }
        if !stepChecker.printTemplateCodeForAllMissingSteps() {
            features.forEach({performFeature($0)})
        }
    }
    
    func performFeature(feature: NativeFeature) {
        // Create a test case to contain our tests
        let testClassName = "\(feature.featureDescription.camelCaseify)Tests"
        let testCaseClassOptional:AnyClass? = objc_allocateClassPair(XCTestCase.self, testClassName, 0)
        guard let testCaseClass = testCaseClassOptional else { XCTFail("Could not create test case class"); return }
        
        // Return the correct number of tests
        let countBlock : @convention(block) (AnyObject) -> UInt = { _ in
            return UInt(feature.scenarios.count)
        }
        let imp = imp_implementationWithBlock(unsafeBitCast(countBlock, AnyObject.self))
        let sel = sel_registerName(strdup("testCaseCount"))
        var success = class_addMethod(testCaseClass, sel, imp, strdup("I@:"))
        XCTAssertTrue(success)
        
        // Return a name
        let nameBlock : @convention(block) (AnyObject) -> String = { _ in
            return feature.featureDescription.camelCaseify
        }
        let nameImp = imp_implementationWithBlock(unsafeBitCast(nameBlock, AnyObject.self))
        let nameSel = sel_registerName(strdup("name"))
        success = class_addMethod(testCaseClass, nameSel, nameImp, strdup("@@:"))
        XCTAssertTrue(success)
        
        // Return a test run class - make it the same as the current run
        let runBlock : @convention(block) (AnyObject) -> AnyObject! = { _ in
            return self.testRun!.dynamicType
        }
        let runImp = imp_implementationWithBlock(unsafeBitCast(runBlock, AnyObject.self))
        let runSel = sel_registerName(strdup("testRunClass"))
        success = class_addMethod(testCaseClass, runSel, runImp, strdup("#@:"))
        XCTAssertTrue(success)
        
        NSLog(feature.description)
        
        // For each scenario, make an invocation that runs through the steps
        let typeString = strdup("v@:")
        feature.scenarios.forEach { scenario in
            NSLog(scenario.description)
            
            // Create the block representing the test to be run
            let block : @convention(block) (XCTestCase)->() = { innerSelf in
                if let background = feature.background {
                    background.stepDescriptions.forEach { innerSelf.performStep($0) }
                }
                scenario.stepDescriptions.forEach { innerSelf.performStep($0) }
            }
            
            // Create the Method and selector
            let imp = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
            let sel = sel_registerName(scenario.selectorCString)
            
            // Add this selector to ourselves
            let success = class_addMethod(testCaseClass, sel, imp, typeString)
            XCTAssertTrue(success, "Failed to add class method \(sel)")
        }
        
        // The test class is constructed, register it
        objc_registerClassPair(testCaseClass)
        
        // Add the test to our test suite
        testCaseClass.testInvocations().sort { (a,b) in NSStringFromSelector(a.selector) > NSStringFromSelector(b.selector) }.forEach { invocation in
            let testCase = (testCaseClass as! XCTestCase.Type).init(invocation: invocation)
            testCase.runTest()
        }
        
    }
}
