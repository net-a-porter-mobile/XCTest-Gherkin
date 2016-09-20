//
//  ClassHelperMethods.swift
//  whats-new
//
//  Created by Sam Dean on 29/10/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

/**
 Returns all subclasses of the given type. For example:

     allSubClassesOf(UIView) { subclasses:[UIView] in
         subclasses.forEach { NSLog(@0) }
     }
 
    would list all the known current subclasses of `UIView`
 
 - parameter baseClass: The base type to match against
 - returns: An array of T, where T is a subclass of `baseClass`
*/
public func allSubclassesOf<T>(_ baseClass: T) -> [T] {
    var matches:[T] = []
    
    // Get all the classes which implement 'baseClass' and return them
    // Helped by code from https://gist.github.com/bnickel/410a1bdc02f12fbd9b5e
    let expectedClassCount = objc_getClassList(nil, 0)
    let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
    let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses) // Huh? We should have gotten this for free.
    let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
    
    (0..<actualClassCount).forEach { i in
        if let currentClass = allClasses[Int(i)] {
            if class_getSuperclass(currentClass) is T {
                matches.append(currentClass as! T)
            }
        }
    }
    
    allClasses.deallocate(capacity: Int(expectedClassCount))
    
    return matches
}
