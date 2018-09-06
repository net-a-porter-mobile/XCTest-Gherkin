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
    let index: Int

    /**
     If the scenario description is 'Test funny things are funny' then the result of calling
     `selectorName` would be `testTestFunnyThingsAreFunny`
     */
    var selectorString: String {
        get { return "test\(self.leftPad(index))\(self.scenarioDescription.camelCaseify)" }
    }
    
    var selectorCString: UnsafeMutablePointer<Int8> {
        get { return strdup(self.selectorString) }
    }
    
    required init(_ description: String, steps: [StepDescription], index: Int = 0) {
        self.scenarioDescription = description
        self.stepDescriptions = steps
        self.index = index
    }
    
    var description: String {
        get {
            return "<\(type(of: self)) \(self.selectorString) \(self.stepDescriptions.count) steps>"
        }
    }
    
    private func leftPad(_ index: Int) -> NSString {
        return NSString(format: "%03i", index)
    }
}

class NativeScenarioOutline: NativeScenario {
    let examples: [NativeExample]

    required init(_ description: String, steps: [StepDescription], examples: [NativeExample], index: Int = 0) {
        self.examples = examples
        super.init(description, steps: steps, index: index)
    }

    required init(_ description: String, steps: [StepDescription], index: Int) {
        fatalError("init(_:steps:index:) has not been implemented")
    }
}

// The "Background" is a number of steps executed before every scenario, so this can be modelled as another scenario.
class NativeBackground: NativeScenario {
    
}
