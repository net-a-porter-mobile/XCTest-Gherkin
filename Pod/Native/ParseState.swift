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
    var tags: [String]
    var name: String?
    var description: [String] = []
    var steps: [StepDescription]
    var exampleLines: [(lineNumber: Int, line: String)]
    var parsingBackground: Bool

    convenience init() {
        self.init(name: nil)
    }
    
    required init(name: String?, parsingBackground: Bool = false, tags: [String] = []) {
        self.name = name
        self.tags = tags
        steps = []
        exampleLines = []
        self.parsingBackground = parsingBackground
    }
    
    private var examples: [NativeExample] {
        get {
            if self.exampleLines.count < 2 { return [] }
            
            var examples: [NativeExample] = []
            
            // The first line is the titles
            let titles = self.exampleLines.first!.line.components(separatedBy: "|").map { $0.trimmingCharacters(in: whitespace) }
            
            // The other lines are the examples themselves
            self.exampleLines.dropFirst().forEach { rawLine in
                let line = rawLine.line.components(separatedBy: "|").map { $0.trimmingCharacters(in: whitespace) }
                
                var pairs: [String: String] = Dictionary()
                
                (0..<titles.count).forEach { n in
                    // Get the title and value for this column
                    let title = titles[n]
                    let value = line.count > n ? line[n] : ""
                    if title != "" && value != "" {
                        pairs[title] = value
                    }
                }
                
                examples.append( (rawLine.lineNumber, pairs ) )
            }
            
            return examples
        }
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
            scenarios.append(NativeScenario(name, steps: self.steps, index: index, tags: tags))
        } else {
            for exampleIndex in 0...self.examples.count - 1 {
                var newSteps = self.steps
                var newName = name
                self.examples[exampleIndex].pairs.forEach { (key, pair) in
                    let toReplace = "<\(key)>"
                    let replaceWith = pair
                    newName = newName.replacingOccurrences(of: toReplace, with: replaceWith)
                    for stepIndex in 0...newSteps.count - 1 {
                        newSteps[stepIndex].expression = newSteps[stepIndex].expression.replacingOccurrences(of: toReplace, with: replaceWith)
                    }
                }

                // Ensuring Scenario names are unique in case the name doesn't have an Example replacement in
                let nameAlreadyExists = scenarios.firstIndex(where: { $0.name == newName })
                if (newName == name)  || (nameAlreadyExists != nil) {
                    newName = "\(newName)-\(exampleIndex)"
                }
                
                scenarios.append(NativeScenario(newName, steps: newSteps, index: index, tags: tags))
            }
        }
        
        self.name = nil
        self.steps = []
        self.exampleLines = []
        
        return scenarios
    }
}
