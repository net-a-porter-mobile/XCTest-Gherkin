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
    var expression: String
    let file: String
    let line: Int
}

class NativeScenario: CustomStringConvertible {
    let name: String
    var scenarioDescription: String = ""
    let stepDescriptions: [StepDescription]
    let index: Int
    let tags: [String]

    /**
     If the scenario description is 'Test funny things are funny' and this is the 3rd test then the result of calling
     `selectorName` would be `test003TestFunnyThingsAreFunny`
     */
    var selectorString: String {
        get { return "test\(self.leftPad(index))\(self.name.camelCaseify)" }
    }
    
    var selectorCString: UnsafeMutablePointer<Int8> {
        get { return strdup(self.selectorString) }
    }
    
    required init(_ name: String, steps: [StepDescription], index: Int = 0, tags: [String] = []) {
        self.name = name
        self.stepDescriptions = steps
        self.index = index
        self.tags = tags
    }
    
    var description: String {
        return "<\(type(of: self)) \(self.selectorString) \(self.stepDescriptions.count) steps>"
    }
    
    private func leftPad(_ index: Int) -> NSString {
        return NSString(format: "%03i", index)
    }
}

class NativeScenarioOutline: NativeScenario {
    let examples: [NativeExample]

    required init(_ name: String, steps: [StepDescription], examples: [NativeExample], index: Int = 0, tags: [String] = []) {
        self.examples = examples
        super.init(name, steps: steps, index: index, tags: tags)
    }

    required init(_ name: String, steps: [StepDescription], index: Int = 0, tags: [String] = []) {
        fatalError("init(_:steps:index:tags:) has not been implemented")
    }

    required init(_ description: String, steps: [StepDescription], index: Int) {
        fatalError("init(_:steps:index:) has not been implemented")
    }
}

// The "Background" is a number of steps executed before every scenario, so this can be modelled as another scenario.
class NativeBackground: NativeScenario {
}
