//
//  NativeFeature.swift
//  Pods
//
//  Created by Sam Dean on 06/11/2015.
//
//

import Foundation

private struct FileTags {
    static var Feature: [String] { return localized(expression: "feature", default: "Feature:") }
    static var Background: [String] { return localized(expression: "background", default: "Background:") }
    static var Scenario: [String] { return localized(expression: "scenario", default: "Scenario:") }
    static var ScenarioOutline: [String] { return localized(expression: "scenarioOutline", default: "Scenario Outline:") }
    static var Examples: [String] { return localized(expression: "examples", default: "Examples:") }
    static let ExampleLine: [String] = ["|"]
    static var Given: [String] { return localized(expression: "given", default: "Given ") }
    static var When: [String] { return localized(expression: "when", default: "When ") }
    static var Then: [String] { return localized(expression: "then", default: "Then ") }
    static var And: [String] { return localized(expression: "and", default: "And ") }

    static var vocabulary: [String: [String: [String]]]? = {
        let bundle = Bundle(for: NativeFeature.self)
        guard let path = bundle.path(forResource: "gherkin-languages", ofType: ".json"),
            let data = FileManager.default.contents(atPath: path),
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: [String: [String]]]
            else {
                print("Failed to read localisation file `gherkin-languages.json`, check that it is in bundle")
                return nil
        }
        var dict = [String: [String: [String]]]()
        json.forEach({ args in
            let (language, values) = args
            var dialect = [String: [String]]()
            values.forEach { args in
                var (expression, variants) = args
                dialect[expression] = variants.map({ variant in
                    if ["feature", "background", "scenario", "scenarioOutline", "examples"].contains(expression) {
                        return variant + ":"
                    } else {
                        return variant
                    }
                }).sorted(by: >)
            }
            dict[language] = dialect
        })
        return dict
    }()

    static func localized(expression: String, default: String) -> [String] {
        let localised = vocabulary?[ParseState.language]?[expression]
        return localised ?? [`default`]
    }
}

public extension NativeTestCase {
    /// Returns all available localisations of keywords
    static var availableLanguages: [String: [String: [String]]]? {
        return FileTags.vocabulary
    }
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
        let lines = contents.components(separatedBy: CharacterSet.newlines).map { $0.trimmingCharacters(in: .whitespaces) }

        let (_, language) = lines.first!.componentsWithPrefix("# language:")
        ParseState.language = language ?? "en"

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
            } else if let newScenarios = state.scenarios(at: scenarios.count) {
                scenarios.append(contentsOf: newScenarios)
            }
            state = ParseState(description: lineSuffix)
        }
        
        // Go through each line in turn
        var lineNumber = 0
        for (lineIndex, line) in lines.enumerated() {
            lineNumber += 1

            // Filter comments (#) and tags (@), also filter white lines
            guard line.first != "#" &&  line.first != "@" && line.count > 0 else { continue }

            if let (linePrefix, lineSuffix) = line.lineComponents() {
                if FileTags.Background.contains(linePrefix) {
                    state = ParseState(description: lineSuffix, parsingBackground: true)
                } else if FileTags.Scenario.contains(linePrefix) || FileTags.ScenarioOutline.contains(linePrefix) {
                    saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)
                } else if FileTags.Given.contains(linePrefix) ||
                    FileTags.When.contains(linePrefix) ||
                    FileTags.Then.contains(linePrefix) ||
                    FileTags.And.contains(linePrefix) {
                    state.steps.append(.init(keyword: linePrefix, expression: lineSuffix, file: path, line: lineNumber))
                } else if FileTags.Examples.contains(linePrefix) {
                    state.exampleLines = []
                } else if FileTags.ExampleLine.contains(linePrefix) {
                    state.exampleLines.append((lineIndex+1, lineSuffix))
                } else {
                    continue
                }
            }
        }
        
        // If we hit the end of the file, we need to make sure we have dealt with
        // the last scenarios
        if let newScenarios = state.scenarios(at: scenarios.count) {
            scenarios.append(contentsOf: newScenarios)
        }
    
        return (background, scenarios)
    }

}

extension String {

    func componentsWithPrefix(_ prefixVariants: [String]) -> (String, String?) {
        for prefixVariant in prefixVariants {
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
        let prefixes = [ FileTags.Feature, FileTags.Scenario, FileTags.Background, FileTags.Given, FileTags.When, FileTags.Then, FileTags.And, FileTags.ScenarioOutline, FileTags.Examples, FileTags.ExampleLine ]
        
        func first(_ a: [[String]]) -> (String, String)? {
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
