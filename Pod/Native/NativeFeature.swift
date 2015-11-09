//
//  NativeFeature.swift
//  Pods
//
//  Created by Sam Dean on 06/11/2015.
//
//

import Foundation

private struct FileTags {
    static let Feature = "Feature:"
    static let Scenario = "Scenario:"
    static let Outline = "Scenario Outline:"
    static let Examples = "Examples:"
    static let Given = "Given"
    static let When = "When"
    static let Then = "Then"
    static let And = "And"
}

class NativeFeature : CustomStringConvertible {
    let featureDescription: String
    let scenarios: [NativeScenario]
    
    required init(description: String, scenarios:[NativeScenario]) {
        self.featureDescription = description
        self.scenarios = scenarios
    }
    
    var description: String {
        get {
            return "<\(self.dynamicType) \(self.featureDescription) \(self.scenarios.count) scenario(s)"
        }
    }
}

extension NativeFeature {
    
    convenience init?(contentsOfURL url: NSURL) {
        // Read in the file
        let contents = try! NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        
        // Get all the lines in the file
        let lines = contents.componentsSeparatedByString("\n")
            .map { $0.stringByTrimmingCharactersInSet(whitepsace) }
        
        guard lines.count > 0 else { return nil }
        
        // The feature description needs to be on the first line - we'll fail this method if it isn't!
        let (_,suffixOption) = lines.first!.componentsWithPrefix(FileTags.Feature)
        guard let suffix = suffixOption else { return nil }

        let featureDescription = suffix
        
        let scenarios = NativeFeature.parseLines(lines)
        
        self.init(description: featureDescription, scenarios: scenarios)
    }
    
    private class func parseLines(inLines: [String]) -> [NativeScenario] {
        
        var state = ParseState()
        var scenarios = Array<NativeScenario>()
        
        func scenarioFromState() {
            guard let d = state.description else { return }
            guard state.steps.count > 0 else { return }
            
            // If we have examples then we need to make more than one scenario
            if state.examples.count > 0 {
                // Replace each matching placeholder in each line with the example data
                state.examples.forEach { example in
                    
                    // This hoop is beacuse the compiler doesn't seem to
                    // recognize mapdirectly on the state.steps object
                    var steps = state.steps
                    steps = state.steps.map { originalStep in
                        var step = originalStep
                        
                        example.forEach { (title, value) in
                            step = step.stringByReplacingOccurrencesOfString("<\(title)>", withString: value)
                        }
                        
                        return step
                    }
                    
                    scenarios.append(NativeScenario(d, steps: steps))
                    
                }
            } else {
                scenarios.append(NativeScenario(d, steps: state.steps))
            }
            
            state = ParseState()
        }
        
        // Go through each line in turn
        var lines = inLines
        while (lines.count > 0) {
            let line = lines.first!
            lines = Array(lines.dropFirst(1))
            
            if !line.isEmpty {
                // What kind of line is it?
                if let (linePrefix, lineSuffix) = line.lineComponents() {
                    
                    switch(linePrefix) {
                    case FileTags.Scenario:
                        scenarioFromState()
                        state = ParseState(description: lineSuffix)
                        
                    case FileTags.Given, FileTags.When, FileTags.Then, FileTags.And:
                        state.steps.append(lineSuffix)
                        
                    case FileTags.Outline:
                        scenarioFromState()
                        state = ParseState(description: lineSuffix)
                        
                    case FileTags.Examples:
                        state.examples = [ [ "name":"bob", "age":"20" ] ]
                        break
                        
                    case FileTags.Feature:
                        break
                        
                    default:
                        // Just ignore lines we don't recognise yet
                        break
                    }
                    
                }
            }

        }
        
        // If we hit the end of the file, we need to make sure we have dealt with
        // the last scenario
        scenarioFromState()
    
        return scenarios
    }

}

private let whitepsace = NSCharacterSet.whitespaceCharacterSet()

extension String {
    
    func componentsWithPrefix(prefix: String) -> (String, String?) {
        guard self.hasPrefix(prefix) else { return (self,nil) }
        
        let index = (prefix as NSString).length
        let suffix = (self as NSString).substringFromIndex(index).stringByTrimmingCharactersInSet(whitepsace)
        return (prefix, suffix)
    }
    
    func lineComponents() -> (String, String)? {
        let prefixes = [ FileTags.Scenario, FileTags.Given, FileTags.When, FileTags.Then, FileTags.And, FileTags.Outline ]
        
        func first(a: [String]) -> (String, String)? {
            if a.count == 0 { return nil }
            let string = a.first!
            let (prefix, suffix) = self.componentsWithPrefix(string)
            if let suffix = suffix {
                return (prefix, suffix)
            } else {
                return first(Array(a.dropFirst(1)))
            }
        }
        
        return first(prefixes)
    }
}

private class ParseState {
    var description: String?
    var steps: [String]
    var examples: [Example]
    
    convenience init() {
        self.init(description: nil)
    }
    
    required init(description: String?) {
        self.description = description
        steps = []
        examples = []
    }
}
