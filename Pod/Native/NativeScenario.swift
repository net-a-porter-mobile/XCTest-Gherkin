//
//  NativeScenario.swift
//  Pods
//
//  Created by Sam Dean on 05/11/2015.
//
//

import Foundation

public class NativeScenario : CustomStringConvertible {
    let scenarioDescription: String
    let stepDescriptions: [String]

    /**
     If the scenario description is 'Test funny things are funny' then the result of calling
     `selectorName` would be `testTestFunnyThingsAreFunny`
     */
    var selectorString: String {
        get { return "test\(self.scenarioDescription.camelCaseify)" }
    }
    
    var selectorCString:UnsafeMutablePointer<Int8> {
        get { return strdup(self.selectorString) }
    }
    
    required public init(_ description: String, steps: [String]) {
        self.scenarioDescription = description
        self.stepDescriptions = steps
    }
    
    public var description:String {
        get {
            return "<\(self.dynamicType) \(self.selectorString) \(self.stepDescriptions.count) steps>"
        }
    }
}
