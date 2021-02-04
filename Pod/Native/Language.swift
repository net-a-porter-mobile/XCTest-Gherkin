//
//  Language.swift
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 09/09/2018.
//

import Foundation

class Language {
    static var current = Language()

    private init() {}

    private(set) var vocabulary: [String: [String: [String]]]? = {
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

    var locale: String! {
        didSet {
            keywords = Keywords()
        }
    }

    private(set) lazy var keywords: Keywords = Keywords()

    func localized(expression: String, default: String, ending: String) -> Keyword {
        let localised = vocabulary?[locale]?[expression] ?? [`default`]
        return Keyword(variants: localised.map { $0.hasSuffix(ending) ? $0 : $0 + ending })
    }

}

struct Keywords {
    let Feature = Language.current.localized(expression: "feature", default: "Feature", ending: ":")
    let Background = Language.current.localized(expression: "background", default: "Background", ending: ":")
    let Scenario = Language.current.localized(expression: "scenario", default: "Scenario", ending: ":")
    let ScenarioOutline = Language.current.localized(expression: "scenarioOutline", default: "Scenario Outline", ending: ":")
    let Examples = Language.current.localized(expression: "examples", default: "Examples", ending: ":")
    let Given = Language.current.localized(expression: "given", default: "Given", ending: " ")
    let When = Language.current.localized(expression: "when", default: "When", ending: " ")
    let Then = Language.current.localized(expression: "then", default: "Then", ending: " ")
    let And = Language.current.localized(expression: "and", default: "And", ending: " ")
    let But = Language.current.localized(expression: "but", default: "But", ending: " ")
    let ExampleLine = Keyword(variants: ["|"])
}

struct Keyword {
    let variants: [String]

    static func ~=(lhs: Keyword, rhs: String) -> Bool {
        return lhs.variants.contains(rhs)
    }
}

public extension NativeTestCase {
    /// Returns all available localisations of keywords
    static var availableLanguages: [String: [String: [String]]]? {
        return Language.current.vocabulary
    }
}
