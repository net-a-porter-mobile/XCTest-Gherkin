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
        return files.map({ return self.parseFeatureFile($0 as! URL)!})
    }
    
    private func parseFeatureFile(_ file: URL) -> NativeFeature? {
        guard let feature = NativeFeature(contentsOfURL: file) else {
            assertionFailure("Could not parse feature at URL \(file.description)")
            return nil
        }
        return feature
    }
}
