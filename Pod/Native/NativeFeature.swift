//
//  NativeFeature.swift
//  Pods
//
//  Created by Sam Dean on 06/11/2015.
//
//

import Foundation

class NativeFeature: CustomStringConvertible {
    let name: String
    let featureDescription: String
    let scenarios: [NativeScenario]
    let background: NativeBackground?
    
    required init(name: String, description: String, scenarios: [NativeScenario], background: NativeBackground?) {
        self.name = name
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
        let lines = contents.components(separatedBy: CharacterSet.newlines).map { $0.trimmingCharacters(in: .whitespaces) }

        let (_, language) = lines.first!.componentsWithPrefix("# language:")
        Language.current.locale = language ?? "en"

        guard lines.count > 0 else { return nil }
        
        self.init(parseLines: lines, path: url.path)
    }
    
    fileprivate convenience init?(parseLines lines: [String], path: String) {
        // The feature name needs to be on the first line - we'll fail this method if it isn't!
        guard case let (_, name?) = lines
            .filter({ $0.first != "#" &&  $0.first != "@" && !$0.isEmpty })
            .first!.componentsWithPrefix(Language.current.keywords.Feature)
            else {
                return nil
        }

        var state = ParseState()
        var scenarios = Array<NativeScenario>()
        var background: NativeBackground?
        var featureDescription: [String]?
        
        func saveBackgroundOrScenarioAndUpdateParseState(_ lineSuffix: String){
            let description = state.description.joined(separator: "\n")
            if let aBackground = state.background() {
                background = aBackground
                background?.scenarioDescription = description
            } else if let newScenarios = state.scenarios(at: scenarios.count) {
                newScenarios.forEach { $0.scenarioDescription = description }
                scenarios.append(contentsOf: newScenarios)
            }
            state = ParseState(name: lineSuffix)
        }
        
        // Go through each line in turn
        var lineNumber = 0
        for (lineIndex, line) in lines.enumerated() {
            lineNumber += 1

            // Filter comments (#) and tags (@), also filter white lines
            guard line.first != "#" &&  line.first != "@" && !line.isEmpty else { continue }

            if let (linePrefix, lineSuffix) = line.lineComponents() {
                switch linePrefix {
                case Language.current.keywords.Background:
                    featureDescription = featureDescription ?? state.description
                    state = ParseState(name: lineSuffix, parsingBackground: true)
                case Language.current.keywords.Scenario,
                     Language.current.keywords.ScenarioOutline:
                    featureDescription = featureDescription ?? state.description
                    saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)
                case Language.current.keywords.Given,
                     Language.current.keywords.When,
                     Language.current.keywords.Then,
                     Language.current.keywords.And,
                     Language.current.keywords.But:
                    state.steps.append(.init(keyword: linePrefix, expression: lineSuffix, file: path, line: lineNumber))
                case Language.current.keywords.Examples:
                    state.exampleLines = []
                case Language.current.keywords.ExampleLine:
                    state.exampleLines.append((lineIndex+1, lineSuffix))
                default:
                    break
                }
            } else {
                state.description.append(line)
            }
        }
        
        // If we hit the end of the file, we need to make sure we have dealt with
        // the last scenarios
        if let newScenarios = state.scenarios(at: scenarios.count) {
            let description = state.description.joined(separator: "\n")
            newScenarios.forEach { $0.scenarioDescription = description }
            scenarios.append(contentsOf: newScenarios)
        }

        self.init(name: name, description: featureDescription?.joined(separator: "\n") ?? "", scenarios: scenarios, background: background)
    }

}

extension String {

    fileprivate func componentsWithPrefix(_ keyword: Keyword) -> (String, String?) {
        for prefixVariant in keyword.variants {
            let (prefix, suffix) = componentsWithPrefix(prefixVariant)
            if let suffix = suffix {
                return (prefix, suffix)
            }
        }
        return (self, nil)
    }

    func componentsWithPrefix(_ prefix: String) -> (String, String?) {
        guard self.hasPrefix(prefix) else { return (self, nil) }
        
        let index = (prefix as NSString).length
        let suffix = (self as NSString).substring(from: index).trimmingCharacters(in: .whitespaces)
        return (prefix, suffix)
    }
    
    func lineComponents() -> (String, String)? {
        let keywords: [Keyword] = [
            Language.current.keywords.Feature,
            Language.current.keywords.Scenario,
            Language.current.keywords.Background,
            Language.current.keywords.Given,
            Language.current.keywords.When,
            Language.current.keywords.Then,
            Language.current.keywords.And,
            Language.current.keywords.But,
            Language.current.keywords.ScenarioOutline,
            Language.current.keywords.Examples,
            Language.current.keywords.ExampleLine
        ]
        
        func first(_ keywords: [Keyword]) -> (String, String)? {
            if keywords.count == 0 { return nil }
            let keyword = keywords.first!
            let (prefix, suffix) = self.componentsWithPrefix(keyword)
            if let suffix = suffix {
                return (prefix, suffix)
            } else {
                return first(Array(keywords.dropFirst(1)))
            }
        }
        
        return first(keywords)
    }
}
