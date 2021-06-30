//
//  NativeFeatureParser.swift
//  Pods
//
//  Created by Marcin Raburski on 05/09/2016.
//
//

import Foundation

struct NativeFeatureParser {
    let path: URL
    
    func parsedFeatures() -> [NativeFeature]? {
        let manager = FileManager.default
        var isDirectory: ObjCBool = ObjCBool(false)
        guard manager.fileExists(atPath: self.path.path, isDirectory: &isDirectory) else {
            assertionFailure("The path does not exist '\(path)'")
            return nil
        }
        
        if isDirectory.boolValue {
            // Get the files from that folder
            if let files = manager.enumerator(at: path, includingPropertiesForKeys: nil, options: [], errorHandler: nil) {
                return self.parseFeatureFiles(files)
            } else {
                assertionFailure("Could not open the path '\(path)'")
            }
            
        } else {
            if let feature = self.parseFeatureFile(path) {
                return [feature]
            }
        }
        return nil
    }
    
    private func parseFeatureFiles(_ files: FileManager.DirectoryEnumerator) -> [NativeFeature] {
        let resourceKeys = Set<URLResourceKey>([.isDirectoryKey])

        return files.compactMap { entry in
            guard
                let url = entry as? URL,
                let values = try? url.resourceValues(forKeys: resourceKeys),
                values.isDirectory == false else {
                    return nil
            }
            return self.parseFeatureFile(entry as! URL)
        }
    }
    
    private func parseFeatureFile(_ file: URL) -> NativeFeature? {
        if file.pathExtension != "feature" { return nil }
        guard var feature = NativeFeature(contentsOfURL: file) else {
            assertionFailure("Could not parse feature at URL \(file.description)")
            return nil
        }
        
        // Note: Ignored tags take precendence over 'wanted' tags
        if let userIgnoreTagsArgumentIndex = CommandLine.arguments.firstIndex(where: { $0.hasPrefix("IgnoreTags=") }) {
            var userIgnoreTags = CommandLine.arguments[userIgnoreTagsArgumentIndex].replacingOccurrences(of: "IgnoreTags=", with: "")
                                                                       .replacingOccurrences(of: "@", with: "")
                                                                       .components(separatedBy: ",")
                                                                       .filter{ !$0.isEmpty }
            userIgnoreTags.append("ignore")
            for index in (0...feature.scenarios.count-1).reversed() {
                if feature.scenarios[index].tags.contains(where: userIgnoreTags.contains) {
                    feature.scenarios.remove(at: index)
                }
            }
        }

        if let userTagsArgumentIndex = CommandLine.arguments.firstIndex(where: { $0.hasPrefix("Tags=") }) {
            var userTags = CommandLine.arguments[userTagsArgumentIndex].replacingOccurrences(of: "Tags=", with: "")
                                                                       .replacingOccurrences(of: "@", with: "")
                                                                       .components(separatedBy: ",")
                                                                       .filter{ !$0.isEmpty }
            userTags.append("include")
            for index in (0...feature.scenarios.count-1).reversed() {
                if !feature.scenarios[index].tags.contains(where: userTags.contains) {
                    feature.scenarios.remove(at: index)
                }
            }
        }

        return feature
    }
}
