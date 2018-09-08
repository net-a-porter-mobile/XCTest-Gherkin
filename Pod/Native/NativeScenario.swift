//
//  NativeScenario.swift
//  Pods
//
//  Created by Sam Dean on 05/11/2015.
//
//

import Foundation

struct StepDescription {
    let keyword: String
    let expression: String
    let file: String
    let line: Int
}

class NativeScenario: CustomStringConvertible {
    let scenarioDescription: String
    let stepDescriptions: [StepDescription]
    let examples: [Example]

    /**
     If the scenario description is 'Test funny things are funny' then the result of calling
     `selectorName` would be `testTestFunnyThingsAreFunny`
     */
    let selectorString: String
    
    let selectorCString: UnsafeMutablePointer<Int8>
    
    required init(_ description: String, steps: [StepDescription], examples: [Example] = []) {
        self.scenarioDescription = description
        self.stepDescriptions = steps
        self.examples = examples
        self.selectorString = "test\(self.scenarioDescription.camelCaseify)"
        self.selectorCString = strdup(self.selectorString)
    }
    
    var description: String {
        return "<\(type(of: self)) \(self.selectorString) \(self.stepDescriptions.count) steps>"
    }
}

// The "Background" is a number of steps executed before every scenario, so this can be modelled as another scenario.
class NativeBackground: NativeScenario {
    
}
