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
        
        // Get all the lines in the file, stripping empty ones
        let lines = contents.componentsSeparatedByString("\n")
            .map { $0.stringByTrimmingCharactersInSet(whitepsace) }
            .filter { (e:String) in !e.isEmpty }
        
        guard lines.count > 0 else { return nil }
        
        // The feature description needs to be on the first line - we'll fail this method if it isn't!
        let (_,suffixOption) = lines.first!.componentsWithPrefix(FileTags.Feature)
        guard let suffix = suffixOption else { return nil }

        let featureDescription = suffix
        
        let scenarios = NativeFeature.parseLines(lines)
        
        self.init(description: featureDescription, scenarios: scenarios)
    }
    
    private class func parseLines(lines: [String]) -> [NativeScenario] {
        
        typealias ParseState = ( description:String?, steps:[String] )
        
        func consumeLines(lines: [String], var state: ParseState, var scenarios:[NativeScenario]) -> [NativeScenario] {
            // If we are at the end of the file just return what we have
            if lines.count == 0 { return scenarios }

            // Get the next line, and strip it from the array of lines
            let line = lines.first!
            let nextLines = Array(lines.dropFirst())

            // This method will take the state and convert it into a scenario
            func scenarioFromState() {
                guard let d = state.description else { return }
                guard state.steps.count > 0 else {return }
                
                scenarios.append(NativeScenario(d, steps: state.steps))
                state = (nil, [])
            }
            
            // If this is a line we are interested in, deal with it
            if let (linePrefix, lineSuffix) = line.lineComponents() {
                
                switch(linePrefix) {
                case FileTags.Scenario:
                    scenarioFromState()
                    state = (lineSuffix, [])
                    
                case FileTags.Given, FileTags.When, FileTags.Then, FileTags.And:
                    state.steps.append(lineSuffix)
                    
                case FileTags.Outline:
                    scenarioFromState()
                    print(ColorLog.red("Scenario Outline not yet supported"))
                    
                default:
                    // Just ignore lines we don't recognise yet
                    break;
                }
                
            }
            
            // We may have consumed more lines, or we need to keep going
            if lines.count == 0 {
                scenarioFromState()
                return scenarios
            }
            
            // Deal with the next line
            return consumeLines(nextLines, state: state, scenarios: scenarios)
        }
        
        return consumeLines(lines, state: (nil, []), scenarios: [])
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
