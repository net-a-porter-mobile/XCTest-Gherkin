//
//  NativeFeatureParser.swift
//  Pods
//
//  Created by Marcin Raburski on 05/09/2016.
//
//

import Foundation

class NativeFeatureParser {
    let path: NSURL
    init(path: NSURL) {
        self.path = path
    }
    
    func parsedFeatures() -> [NativeFeature]? {
        let manager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = ObjCBool(false)
        guard manager.fileExistsAtPath(self.path.path!, isDirectory: &isDirectory) else {
            assertionFailure("The path doesn not exist '\(path)'")
            return nil
        }
        
        if isDirectory {
            // Get the files from that folder
            if let files = manager.enumeratorAtURL(path, includingPropertiesForKeys: nil, options: [], errorHandler: nil) {
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
    
    func parseFeatureFiles(files: NSDirectoryEnumerator) -> [NativeFeature] {
        return files.map({ return self.parseFeatureFile($0 as! NSURL)!})
    }
    
    func parseFeatureFile(file: NSURL) -> NativeFeature? {
        guard let feature = NativeFeature(contentsOfURL:file, stepChecker:GherkinStepsChecker()) else {
            assertionFailure("Could not parse feature at URL \(file.description)")
            return nil
        }
        return feature
    }
}
