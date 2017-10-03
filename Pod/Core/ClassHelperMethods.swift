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
    var matches: [T] = []

    for currentClass in allClasses() {

        guard class_getRootSuperclass(currentClass) == NSObject.self else {
            continue
        }

        if currentClass is T {
            matches.append(currentClass as! T)
        }
    }

    return matches
}

fileprivate func class_getRootSuperclass(_ type: AnyObject.Type) -> AnyObject.Type {
    guard let superclass = class_getSuperclass(type) else { return type }

    return class_getRootSuperclass(superclass)
}

fileprivate func allClasses() -> [AnyClass] {
    let expectedClassCount = objc_getClassList(nil, 0) * 2
    let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
    let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses)  // Huh? We should have gotten this for free.
    let actualClassCount = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

    var classes = [AnyClass]()
    for i in 0 ..< actualClassCount {
        if let currentClass: AnyClass = allClasses[Int(i)] {
            classes.append(currentClass)
        }
    }

    allClasses.deallocate(capacity: Int(expectedClassCount))

    return classes
}
