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

class NativeFeature: CustomStringConvertible {
    let featureDescription: String
    let scenarios: [NativeScenario]
    let background: NativeBackground?
    
    required init(description: String, scenarios: [NativeScenario], background: NativeBackground?) {
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
            return "<\(type(of: self)) \(self.featureDescription) Background: \(backgroundDescription). \(self.scenarios.count) scenario(s)>"
        }
    }
}

extension NativeFeature {
    
    convenience init?(contentsOfURL url: URL) {
        guard let data = try? Data(contentsOf: url), let contents = String(data: data, encoding: .utf8) else { return nil }

        // Get all the lines in the file
        let lines = contents.components(separatedBy: CharacterSet.newlines).map { $0.trimmingCharacters(in: whitespace) }

        guard lines.count > 0 else { return nil }
        
        // The feature description needs to be on the first line - we'll fail this method if it isn't!
        let (_, suffixOption) = lines.filter({ $0.first != "#" &&  $0.first != "@" && $0.count > 0 }).first!.componentsWithPrefix(FileTags.Feature)
        guard let featureDescription = suffixOption else { return nil }
        
        let feature = NativeFeature.parseLines(lines, path: url.path)
        
        self.init(description: featureDescription, scenarios: feature.scenarios, background: feature.background)
    }
    
    fileprivate class func parseLines(_ lines: [String], path: String) -> (background: NativeBackground?, scenarios: [NativeScenario]) {
        
        var state = ParseState()
        var scenarios = Array<NativeScenario>()
        var background: NativeBackground?
        
        func saveBackgroundOrScenarioAndUpdateParseState(_ lineSuffix: String){
            if let aBackground = state.background() {
                background = aBackground
            } else if let newScenario = state.scenario() {
                scenarios.append(newScenario)
            }
            state = ParseState(description: lineSuffix)
        }
        
        // Go through each line in turn
        var lineNumber = 0
        for (lineIndex, line) in lines.enumerated() {
            lineNumber += 1

            // Filter comments (#) and tags (@), also filter white lines
            guard line.first != "#" &&  line.first != "@" && line.count > 0 else { continue }

            // What kind of line is it?
            if let (linePrefix, lineSuffix) = line.lineComponents() {

                switch (linePrefix) {

                case FileTags.Background :
                    state = ParseState(description: lineSuffix, parsingBackground: true)

                case FileTags.Scenario :
                    saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)

                case FileTags.Outline:
                    saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)

                case FileTags.Given, FileTags.When, FileTags.Then, FileTags.And:
                    state.steps.append(.init(keyword: linePrefix, expression: lineSuffix, file: path, line: lineNumber))

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
        
        // If we hit the end of the file, we need to make sure we have dealt with
        // the last scenarios
        if let newScenario = state.scenario() {
            scenarios.append(newScenario)
        }
    
        return (background, scenarios)
    }

}

private let whitespace = CharacterSet.whitespaces

extension String {
    
    func componentsWithPrefix(_ prefix: String) -> (String, String?) {
        guard self.hasPrefix(prefix) else { return (self, nil) }
        
        let index = (prefix as NSString).length
        let suffix = (self as NSString).substring(from: index).trimmingCharacters(in: whitespace)
        return (prefix, suffix)
    }
    
    func lineComponents() -> (String, String)? {
        let prefixes = [ FileTags.Scenario, FileTags.Background, FileTags.Given, FileTags.When, FileTags.Then, FileTags.And, FileTags.Outline, FileTags.Examples, FileTags.ExampleLine ]
        
        func first(_ a: [String]) -> (String, String)? {
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
