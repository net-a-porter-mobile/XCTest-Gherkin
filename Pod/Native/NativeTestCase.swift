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

private struct FileTags {
    static let Feature = "Feature: "
    static let Scenario = "Scenario: "
    static let Given = "Given"
    static let When = "When"
    static let Then = "Then"
    static let And = "And"
}

public class NativeTestCase : XCTestCase {
    
    public var path:NSURL?
    
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
        
        files.forEach { parseAndRunFeature($0 as! NSURL) }
    }
    
    private func parseAndRunFeature(url: NSURL) {
        print("Running tests from \(url.lastPathComponent!)")
        
        // Read in the file
        let contents = try! NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        
        // The file will be made up of lots of scenarios
        let lines = contents.componentsSeparatedByString("\n")
        
        var featureDescription: String = "UnnamedFeature"
        
        // We will build up enough state here while we parse the file to
        // create some NativeScenarios
        var scenarioDescription:String?
        var scenarioSteps:[String] = []
        
        var scenarios:[NativeScenario] = []
        
        // This isn't very functional at all - it will take the current state and append
        // a scenario to the array of scenarios
        func appendScenarioFromCurrentState() {
            if let desc = scenarioDescription
                where scenarioSteps.count > 0 {
                    scenarios.append(NativeScenario(desc, steps: scenarioSteps))

                    scenarioDescription = nil
                    scenarioSteps = []
            }
        }
        
        // Go over each line and create our scenarios
        lines.map {
            $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }.forEach { line in
            guard let (linePrefix, lineSuffix) = line.lineComponents() else { return }
            
            switch(linePrefix) {
            case FileTags.Feature:
                featureDescription = lineSuffix
            
            case FileTags.Scenario:
                appendScenarioFromCurrentState()
                
                scenarioDescription = lineSuffix
                scenarioSteps = []
                
            case FileTags.Given, FileTags.When, FileTags.Then, FileTags.And:
                scenarioSteps.append(lineSuffix)
                
            default:
                // Just ignore lines we don't recognise yet
                break;
            }
        }
        
        // Make sure we don't have any stray state at the end of the file
        appendScenarioFromCurrentState()
        
        // Create a test case to contain our tests
        let testClassName = "\(featureDescription.camelCaseify)Tests"
        let testCaseClassOptional:AnyClass? = objc_allocateClassPair(XCTestCase.self, testClassName, 0)
        guard let testCaseClass = testCaseClassOptional else { XCTFail("Could not create test case class"); return }
        
        // Return the correct number of tests
        let countBlock : @convention(block) (AnyObject) -> UInt = { _ in
            return UInt(scenarios.count)
        }
        let imp = imp_implementationWithBlock(unsafeBitCast(countBlock, AnyObject.self))
        let sel = sel_registerName(strdup("testCaseCount"))
        var success = class_addMethod(testCaseClass, sel, imp, strdup("I@:"))
        XCTAssertTrue(success)
        
        // Return a name
        let nameBlock : @convention(block) (AnyObject) -> String = { _ in
            return featureDescription.camelCaseify
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
        
        // For each scenario, make an invocation that runs through the steps
        let typeString = strdup("v@:")
        scenarios.forEach { scenario in
            print(scenario.description)
            
            // Create the block representing the test to be run
            let block : @convention(block) (AnyObject)->() = { (cmd) in
                scenario.stepDescriptions.forEach { self.performStep($0) }
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
        testCaseClass.testInvocations().forEach { invocation in
            let testCase = (testCaseClass as! XCTestCase.Type).init(invocation: invocation)
            testCase.runTest()
        }
        
    }
}

private let whitepsace = NSCharacterSet.whitespaceCharacterSet()

extension String {
    
    private func componentsWithPrefix(prefix: String) -> (String, String) {
        let index = (prefix as NSString).length
        let suffix = (self as NSString).substringFromIndex(index).stringByTrimmingCharactersInSet(whitepsace)
        return (prefix, suffix)
    }
    
    private func lineComponents() -> (String, String)? {
        let prefixes = [ FileTags.Feature, FileTags.Scenario, FileTags.Given, FileTags.When, FileTags.Then, FileTags.And ]
        
        func first(a: [String]) -> (String, String)? {
            if a.count == 0 { return nil }
            let p = a.first!
            if (self.hasPrefix(p)) { return self.componentsWithPrefix(p) }
            return first(Array(a.dropFirst(1)))
        }
        
        return first(prefixes)
    }
}
