//
//  Example.swift
//  whats-new
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

// Yep, turns out that an example is just a dictionary :)

typealias ExampleTitle = String
typealias ExampleValue = String

/**
 An Example represents a single row in the Examples(...) block in a test
 */
typealias Example = [ExampleTitle: ExampleValue]
