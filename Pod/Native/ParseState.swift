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
    var description: String?
    var steps: [StepDescription]
    var exampleLines: [(lineNumber: Int, line: String)]
    var parsingBackground: Bool

    convenience init() {
        self.init(description: nil)
    }
    
    required init(description: String?, parsingBackground: Bool = false) {
        self.description = description
        steps = []
        exampleLines = []
        self.parsingBackground = parsingBackground
    }
    
    private var examples: [Example] {
        get {
            if self.exampleLines.count < 2 { return [] }
            
            var examples: [Example] = []
            
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
                    
                    pairs[title] = value
                }
                
                examples.append( (rawLine.lineNumber, pairs ) )
            }
            
            return examples
        }
    }
    
    func background() -> NativeBackground? {
        guard parsingBackground, let description = self.description, self.steps.count > 0 else { return nil }
        
        return NativeBackground(description, steps: self.steps)
    }
    
    func scenarios(at index: Int) -> [NativeScenario]? {
        guard let description = self.description, self.steps.count > 0 else { return nil }
        
        var scenarios = Array<NativeScenario>()
        
        scenarios.append(NativeScenario(description, steps: self.steps, examples: self.examples, index: index))

        self.description = nil
        self.steps = []
        self.exampleLines = []
        
        return scenarios
    }
}
