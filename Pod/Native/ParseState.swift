//
//  ParseState.swift
//  Pods
//
//  Created by Sam Dean on 09/11/2015.
//
//

import Foundation

private let whitespace = CharacterSet.whitespaces

class ParseState {
    var name: String?
    var description: [String] = []
    var steps: [StepDescription]
    var exampleLines: [(lineNumber: Int, line: String)]?
    var dataTableLines: [String]?
    var parsingBackground: Bool

    convenience init() {
        self.init(name: nil)
    }
    
    required init(name: String?, parsingBackground: Bool = false) {
        self.name = name
        steps = []
        self.parsingBackground = parsingBackground
    }
    
    private var examples: [NativeExample] {
        guard let exampleLines = exampleLines else { return [] }
        if exampleLines.count < 2 { return [] }
        
        var examples: [NativeExample] = []
        
        // The first line is the titles
        let titles = exampleLines.first!.line
            .components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: whitespace) }
            .dropFirst().dropLast()
        
        // The other lines are the examples themselves
        exampleLines.dropFirst().forEach { rawLine in
            let line = rawLine.line
                .components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: whitespace) }
                .dropFirst().dropLast()
            
            var pairs: [String: String] = Dictionary()

            // Get the title and value for this column
            titles.indices.forEach {
                pairs[titles[$0]] = line[$0]
            }
            examples.append((rawLine.lineNumber, pairs))
        }
        
        return examples
    }

    func background() -> NativeBackground? {
        guard parsingBackground, let name = self.name, self.steps.count > 0 else { return nil }
        
        return NativeBackground(name, steps: self.steps)
    }
    
    func scenarios(at index: Int) -> [NativeScenario]? {
        guard let name = self.name, self.steps.count > 0 else { return nil }
        
        var scenarios = Array<NativeScenario>()
        
        // If we have no examples then we have one scenario.
        // Otherwise we need to make more than one scenario.
        if self.examples.isEmpty {
            if let dataTableLines = self.dataTableLines {
                let lastStep = self.steps.removeLast()
                self.steps.append(
                    StepDescription(
                        keyword: lastStep.keyword,
                        expression: lastStep.expression + " \(dataTableLines.joined(separator: ","))",
                        file: lastStep.file,
                        line: lastStep.line
                    )
                )
            }
            scenarios.append(NativeScenario(name, steps: self.steps, index: index))
        } else {
            scenarios.append(NativeScenarioOutline(name, steps: self.steps, examples: self.examples, index: index))
        }
        
        self.name = nil
        self.steps = []
        self.exampleLines = nil
        self.dataTableLines = nil

        return scenarios
    }
}
