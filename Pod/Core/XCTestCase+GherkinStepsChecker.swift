//
//  GherkinStepsChecker.swift
//  Pods
//
//  Created by Samuël Maljaars on 10/06/16.
//
//

import Foundation
import XCTest

class GherkinStepsChecker: XCTestCase {
    
    private var missingStepsImplementations = [String]()
    
    func loadDefinedSteps(){
        loadAllStepsIfNeeded()
    }
    
    func matchGherkinStepExpressionToStepDefinitions(expression: String){
        
        // Get the step(s) which match this expression
        let range = NSMakeRange(0, expression.characters.count)
        let matches = state.steps.map { (step: Step) -> (step:Step, match:NSTextCheckingResult)? in
            if let match = step.regex.firstMatchInString(expression, options: [], range: range) {
                return (step:step, match:match)
            } else {
                return nil
            }
            }.flatMap { $0! }
        
        switch matches.count {
            
        case 0:
            XCTFail("Step definition not found for '\(ColorLog.red(expression))'")
            let stepImplementation = "step(\"\(expression)"+"\") {XCTAssertTrue(true)}"
            missingStepsImplementations.append(stepImplementation)
            
        case 1:
            //no issues, so proceed
            break;
            
        default:
            matches.forEach { NSLog("Matching step : \(String(reflecting: $0.step))") }
            XCTFail("Multiple step definitions found for : '\(ColorLog.red(expression))'")
        }
        
    }
    
    func printTemplateCodeForAllMissingSteps() -> Bool {
        guard missingStepsImplementations.count > 0 else {
            ColorLog.lightGreen("All Gherkin steps have been defined in a StepDefiner subclass")
            return false
        }
        
        self.dynamicType.printStepDefinitions()
        
        print(ColorLog.red("Copy paste these steps in a StepDefiner subclass:"))
        print("-------------")
        missingStepsImplementations.forEach({
            print($0)
        })
        print("-------------")
        return true
    }
}
