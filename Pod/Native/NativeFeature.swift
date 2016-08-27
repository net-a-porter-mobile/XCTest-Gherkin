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
    static let Background = "Background:"
    static let Scenario = "Scenario:"
    static let Outline = "Scenario Outline:"
    static let Examples = "Examples:"
    static let ExampleLine = "|"
    static let Given = "Given"
    static let When = "When"
    static let Then = "Then"
    static let And = "And"
}

class NativeFeature : CustomStringConvertible {
    let featureDescription: String
    let scenarios: [NativeScenario]
    let background: NativeBackground?
    
    required init(description: String, scenarios:[NativeScenario], background: NativeBackground?) {
        self.featureDescription = description
        self.scenarios = scenarios
        self.background = background
    }
    
    var description: String {
        get {
            var backgroundDescription = "No background"
            if let myBackground = self.background {
                backgroundDescription = myBackground.description
            }
            return "<\(self.dynamicType) \(self.featureDescription) Background: \(backgroundDescription). \(self.scenarios.count) scenario(s)>"
        }
    }
}

extension NativeFeature {
    
    convenience init?(contentsOfURL url: NSURL, stepChecker: GherkinStepsChecker) {
        // Read in the file
        let contents = try! NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        
        // Replace new line character that is sometimes used if the Gherkin files have been written on a Windows machine.
        let contentsFixedWindowsNewLineCharacters = contents.stringByReplacingOccurrencesOfString("\r\n", withString: "\n")
        
        // Get all the lines in the file
        var lines = contentsFixedWindowsNewLineCharacters.componentsSeparatedByString("\n").map { $0.stringByTrimmingCharactersInSet(whitespace) }

        // Filter comments (#) and tags (@), also filter white lines
        lines = lines.filter { $0.characters.first != "#" &&  $0.characters.first != "@" && $0.characters.count > 0}

        guard lines.count > 0 else { return nil }
        
        // The feature description needs to be on the first line - we'll fail this method if it isn't!
        let (_,suffixOption) = lines.first!.componentsWithPrefix(FileTags.Feature)
        guard let featureDescription = suffixOption else { return nil }
        
        let feature = NativeFeature.parseLines(lines)
        
        stepChecker.loadDefinedSteps()
        
        feature.scenarios.forEach({
            $0.stepDescriptions.forEach({
                stepChecker.matchGherkinStepExpressionToStepDefinitions($0)
            })
        })
        
        feature.background?.stepDescriptions.forEach({
            stepChecker.matchGherkinStepExpressionToStepDefinitions($0)
        })
        
        self.init(description: featureDescription, scenarios: feature.scenarios, background: feature.background)
    }
    
    private class func parseLines(lines: [String]) -> (background: NativeBackground?, scenarios:[NativeScenario]) {
        
        var state = ParseState()
        var scenarios = Array<NativeScenario>()
        var background: NativeBackground?
        
        func saveBackgroundOrScenarioAndUpdateParseState(lineSuffix: String){
            if let aBackground = state.background() {
                background = aBackground
            } else if let newScenarios = state.scenarios() {
                scenarios.appendContentsOf(newScenarios)
            }
            state = ParseState(description: lineSuffix)
        }
        
        // Go through each line in turn
        for (lineIndex,line) in lines.enumerate() {
            
            if !line.isEmpty {
                // What kind of line is it?
                if let (linePrefix, lineSuffix) = line.lineComponents() {
                    
                    switch(linePrefix) {
                        
                    case FileTags.Background :
                        state = ParseState(description: lineSuffix, parsingBackground: true)
                        
                    case FileTags.Scenario :
                        saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)
                        
                    case FileTags.Given, FileTags.When, FileTags.Then, FileTags.And:
                        state.steps.append(lineSuffix)
                        
                    case FileTags.Outline:
                        saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)
                        
                    case FileTags.Examples:
                        // Prep the examples array for examples
                        state.exampleLines = []

                    case FileTags.ExampleLine:
                        state.exampleLines.append( (lineIndex+1, lineSuffix) )
                        
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
        // the last scenarios
        if let newScenarios = state.scenarios() {
            scenarios.appendContentsOf(newScenarios)
        }
    
        return (background, scenarios)
    }

}

private let whitespace = NSCharacterSet.whitespaceCharacterSet()

extension String {
    
    func componentsWithPrefix(prefix: String) -> (String, String?) {
        guard self.hasPrefix(prefix) else { return (self,nil) }
        
        let index = (prefix as NSString).length
        let suffix = (self as NSString).substringFromIndex(index).stringByTrimmingCharactersInSet(whitespace)
        return (prefix, suffix)
    }
    
    func lineComponents() -> (String, String)? {
        let prefixes = [ FileTags.Scenario, FileTags.Background, FileTags.Given, FileTags.When, FileTags.Then, FileTags.And, FileTags.Outline, FileTags.Examples, FileTags.ExampleLine ]
        
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
