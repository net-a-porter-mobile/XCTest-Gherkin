//
//  NativeFeature.swift
//  Pods
//
//  Created by Sam Dean on 06/11/2015.
//
//

import Foundation

private struct FileTag {
    let variants: [String]

    static func ~=(lhs: FileTag, rhs: String) -> Bool {
        return lhs.variants.contains(rhs)
    }

    static private(set) var Feature: FileTag!
    static private(set) var Background: FileTag!
    static private(set) var Scenario: FileTag!
    static private(set) var ScenarioOutline: FileTag!
    static private(set) var Examples: FileTag!
    static private(set) var ExampleLine: FileTag!
    static private(set) var Given: FileTag!
    static private(set) var When: FileTag!
    static private(set) var Then: FileTag!
    static private(set) var And: FileTag!

    static var language: String = "en" {
        didSet {
            Feature = localized(expression: "feature", default: "Feature", ending: ":")
            Background = localized(expression: "background", default: "Background", ending: ":")
            Scenario = localized(expression: "scenario", default: "Scenario", ending: ":")
            ScenarioOutline = localized(expression: "scenarioOutline", default: "Scenario Outline", ending: ":")
            Examples = localized(expression: "examples", default: "Examples", ending: ":")
            ExampleLine = FileTag(variants: ["|"])
            Given = localized(expression: "given", default: "Given", ending: " ")
            When = localized(expression: "when", default: "When", ending: " ")
            Then = localized(expression: "then", default: "Then", ending: " ")
            And = localized(expression: "and", default: "And", ending: " ")
        }
    }

    static var vocabulary: [String: [String: [String]]]? = {
        let bundle = Bundle(for: NativeFeature.self)
        guard let path = bundle.path(forResource: "gherkin-languages", ofType: ".json"),
            let data = FileManager.default.contents(atPath: path),
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: [String: [String]]]
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
                dialect[expression] = variants.sorted(by: >)
            }
            dict[language] = dialect
        })
        return dict
    }()

    static func localized(expression: String, default: String, ending: String) -> FileTag {
        let localised = vocabulary?[FileTag.language]?[expression] ?? [`default`]
        return FileTag(variants: localised.map { $0.hasSuffix(ending) ? $0 : $0 + ending })
    }
}

public extension NativeTestCase {
    /// Returns all available localisations of keywords
    static var availableLanguages: [String: [String: [String]]]? {
        return FileTag.vocabulary
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
        FileTag.language = language ?? "en"

        guard lines.count > 0 else { return nil }
        
        // The feature description needs to be on the first line - we'll fail this method if it isn't!
        let (_, suffixOption) = lines.filter({ $0.first != "#" &&  $0.first != "@" && $0.count > 0 }).first!.componentsWithPrefix(FileTag.Feature)
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
                switch linePrefix {
                case FileTag.Background:
                    state = ParseState(description: lineSuffix, parsingBackground: true)
                case FileTag.Scenario, FileTag.ScenarioOutline:
                    saveBackgroundOrScenarioAndUpdateParseState(lineSuffix)
                case FileTag.Given, FileTag.When, FileTag.Then, FileTag.And:
                    state.steps.append(.init(keyword: linePrefix, expression: lineSuffix, file: path, line: lineNumber))
                case FileTag.Examples:
                    state.exampleLines = []
                case FileTag.ExampleLine:
                    state.exampleLines.append((lineIndex+1, lineSuffix))
                default:
                    break
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

    fileprivate func componentsWithPrefix(_ tag: FileTag) -> (String, String?) {
        for prefixVariant in tag.variants {
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
        let tags: [FileTag] = [
            FileTag.Feature,
            FileTag.Scenario,
            FileTag.Background,
            FileTag.Given,
            FileTag.When,
            FileTag.Then,
            FileTag.And,
            FileTag.ScenarioOutline,
            FileTag.Examples,
            FileTag.ExampleLine
        ]
        
        func first(_ tags: [FileTag]) -> (String, String)? {
            if tags.count == 0 { return nil }
            let tag = tags.first!
            let (prefix, suffix) = self.componentsWithPrefix(tag)
            if let suffix = suffix {
                return (prefix, suffix)
            } else {
                return first(Array(tags.dropFirst(1)))
            }
        }
        
        return first(tags)
    }
}
