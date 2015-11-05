//
//  File.swift
//  whats-new
//
//  Created by Sam Dean on 26/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

import XCTest

/**

Why is there so much global state here?

I wanted this to work with both KIFTestCase and UITestCase which meant extending 
UITestCase - a subclass wouldn't work with both of them.

This meant that I couldn't have properties and given we are running UI tests
we're inherently single threaded anyway so meh.

*/

// The list of all steps the system knows about
private var steps = Set<Step>()

// Used to track step nesting i.e. steps calling out to other steps
private var currentStepDepth:Int = 0

// When we are in an Outline block, this defines the examples to loop over
private var examples:[Example]? = nil

// The current example the Outline is running over
private var currentExample:Example? = nil

// Store the name of the current test to help debugging output
private var currentTestName:String = "NO TESTS RUN YET"

/**
 Add Gherkin methods to XCTestCase
*/
public extension XCTestCase {

    /**
     This will populate the static steps array if it's empty.
     */
    private func loadAllStepsIfNeeded() {
        if steps.count == 0 {
            // Create an instance of each step definer and call it's defineSteps
            // method
            allSubclassesOf(StepDefiner).forEach { subclass in
                subclass.init(test: self).defineSteps()
            }
            
            XCTAssert(steps.count > 0, "No steps have been defined - there must be at least one subclass of StepDefiner which defines at least one step!")
        }
    }
    
    // MARK: Debugging methods
    /**
    Dumps out a list of all the steps currently known, including the file and line they were defined on
    
    It's a class method so just call `XCTestCase.printStepDefinitions()` anywhere you like, including in the debugger.
    
    */
    class func printStepDefinitions() {
        print("Defined steps")
        print("-------------")
        print(steps.map { String(reflecting: $0) }.sort().joinWithSeparator("\n"))
        print("-------------")
    }
    
    /**
     Run the step matching the specified expression
     */
    func Given(expression: String) -> Self { return performStep(expression) }
    
    /**
     Run the step matching the specified expression
     */
    func When(expression: String) -> Self { return performStep(expression) }
    
    /**
     Run the step matching the specified expression
     */
    func Then(expression: String) -> Self { return performStep(expression) }
    
    /**
     Run the step matching the specified expression
     */
    func And(expression: String) -> Self { return performStep(expression) }
    
    /**
     Supply a set of example data to the test. This must be done before calling `Outline`.
     
     If you specify a set of examples but don't run the test inside an `Outline { }` block then it won't do anything!
     
     - parameter titles: The titles for each column; these are the keys used to replace the placeholders in each step
     - parameter allValues: This is an array of columns - each array will be used as a single test
     */
    func Examples(titles:[String], _ allValues:[String]...) {
        XCTAssert(allValues.count > 0, "You must pass at least one set of example data")
        
        // TODO: Hints at a reduce, but we're going over two arrays at once . . . :|
        var accumulator = Array<Example>()
        allValues.forEach { values in
            XCTAssertEqual(values.count, titles.count, "Each example must be the same size as the titles (was \(values.count), expected \(titles.count))")
            
            // Loop over both titles and values, creating a dictionary (i.e. an Example)
            var example = Example()
            (0..<titles.count).forEach { n in
                example[titles[n]] = values[n]
            }
            
            accumulator.append(example)
        }
        
        examples = accumulator
    }
    
    /**
     Run the following steps as part of an outline - this will replace any placeholders with each example in turn.

     You must have setup the example cases before calling this; use `Example(...)` to do this.
     
     - parameter routine: A block containing your Given/When/Then which will be run once per example
     */
    func Outline( @noescape routine:()->() ) {
        
        XCTAssertNotNil(examples, "You need to define examples before running an Outline block - use Examples(...)");
        XCTAssert(examples!.count > 0, "You've called Examples but haven't passed anything in. Nice try.")
        
        examples!.forEach { example in
            currentExample = example
            routine()
            currentExample = nil
        }
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
    func addStep(expression: String, file: String, line: Int, _ function: ([String])->()) {
        let step = Step(expression, file: file, line: line, function)
        steps.insert(step);
    }
    
    /**
     Finds and performs a step test based on expression
     */
    func performStep(initialExpression: String) -> Self {
        // Get a mutable copy - if we are in an outline we might be changing this
        var expression = initialExpression
        
        // Make sure that we have created our steps
        loadAllStepsIfNeeded()
        
        // If we are in an example, transform the step to reflect the current example's value
        if let example = currentExample {
            // For each field in the example, go through the step expression and replace the placeholders if needed
            example.forEach { (key, value) in
                let needle = "<\(key)>"
                expression = (expression as NSString).stringByReplacingOccurrencesOfString(needle, withString: value)
            }
        }
        
        // Get the range of expression to match over - this is all of it
        let range = NSMakeRange(0, expression.characters.count)
        let options:NSMatchingOptions = []
        
        let matchingSteps = steps.filter { (step: Step) -> Bool in
            return step.regex.numberOfMatchesInString(expression, options: options, range: range) > 0
        }
        
        switch matchingSteps.count {
            
        case 0:
            self.dynamicType.printStepDefinitions()
            XCTFail("Step definition not found for '\(ColorLog.red(expression))'")
            
        case 1:
            // Get the step and the matches inside it
            let step = matchingSteps.first!
            let match = step.regex.firstMatchInString(expression, options: options, range: range)!
            
            // Covert them to strings to pass back into the step function
            // TODO: This should really only need to be a map function :(
            var matchStrings = Array<String>()
            for i in 1..<match.numberOfRanges {
                let range = match.rangeAtIndex(i)
                let string = (expression as NSString).substringWithRange(range)
                matchStrings.append(string)
            }
            
            // If this the first step, debug the test name as well
            if currentStepDepth == 0 {
                let rawName = String(self.invocation!.selector)
                let testName = rawName.hasPrefix("test") ? (rawName as NSString).substringFromIndex(4) : rawName
                if testName != currentTestName {
                    NSLog("steps from \(ColorLog.darkGreen(testName.humanReadableString))")
                    currentTestName = testName
                }
            }
            
            // Debug the step name
            let coloredExpression = currentStepDepth == 0 ? ColorLog.green(expression) : ColorLog.lightGreen(expression)
            NSLog("step \(currentStepDepthString())\(coloredExpression)")
            
            // Run the step
            currentStepDepth++
            step.function(matchStrings)
            currentStepDepth--
            
        default:
            XCTFail("Multiple steps found for : \(expression)")
        }
        
        return self
    }
    
    /**
     Converts the current step depth into a string to use for padding
     
     - returns: A String of spaces equal to the current step depth
     */
    private func currentStepDepthString() -> String {
        return Repeat<String>(count: currentStepDepth, repeatedValue: " ").joinWithSeparator("")
    }
}
