//
//  Example.swift
//  whats-new
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation
import XCTest

// Yep, turns out that an example is just a dictionary :)

typealias ExampleTitle = String
typealias ExampleValue = ExampleStringRepresentable

/**
 An Example represents a single row in the Examples(...) block in a test
 */
typealias Example = [ExampleTitle: ExampleValue]

public typealias ExampleStringRepresentable = MatchedStringRepresentable

public extension XCTestCase {
    /**
     Supply a set of example data to the test. This must be done before calling `Outline`.

     If you specify a set of examples but don't run the test inside an `Outline { }` block then it won't do anything!

     - parameter titles: The titles for each column; these are the keys used to replace the placeholders in each step
     - parameter allValues: This is an array of columns - each array will be used as a single test
     */
    func Examples(_ titles: [String], _ allValues: [ExampleStringRepresentable]...) {
        var all = [titles]
        let values = allValues.map { $0.map { String(describing: $0) } }
        all.append(contentsOf: values)
        Examples(all)
    }


    @nonobjc
    func Examples(_ values: [[String: ExampleStringRepresentable]]) {
        var titles = [String]()
        var allValues = [[ExampleStringRepresentable]](repeating: [], count: values.count)

        values.enumerated().forEach { (example) in
            example.element.sorted(by: { $0.key < $1.key }).forEach({
                if !titles.contains($0.key) {
                    titles.append($0.key)
                }
                allValues[example.offset] = allValues[example.offset] + [$0.value]
            })
        }
        Examples([titles] + allValues)
    }

    /**
     If you want to reuse examples between tests then you can just pass in an array of examples directly.

     let examples = [
         [ "title", "age" ],
         [ "a",     "20"  ],
         [ "b",     "25"  ]
     ]

     ...

     Examples(examples)

     */
    func Examples(_ values: [[ExampleStringRepresentable]]) {
        precondition(values.count > 1, "You must pass at least one set of example data")

        // Split out the titles and the example data
        let titles = values.first!
        let allValues = values.dropFirst()

        // TODO: Hints at a reduce, but we're going over two arrays at once . . . :|
        var accumulator = Array<Example>()
        allValues.forEach { values in
            precondition(values.count == titles.count, "Each example must be the same size as the titles (was \(values.count), expected \(titles.count))")

            // Loop over both titles and values, creating a dictionary (i.e. an Example)
            var example = Example()
            (0..<titles.count).forEach { n in
                let title = String(describing: titles[n])
                let value = String(describing: values[n])
                example[title] = value
            }

            accumulator.append(example)
        }

        state.examples = accumulator
    }

    /**
     Run the following steps as part of an outline - this will replace any placeholders with each example in turn.

     You must have setup the example cases before calling this; use `Example(...)` to do this.

     - parameter routine: A block containing your Given/When/Then which will be run once per example
     */
    func Outline(_ routine: ()->()) {
        precondition(state.examples != nil, "You need to define examples before running an Outline block - use Examples(...)");
        precondition(state.examples!.count > 0, "You've called Examples but haven't passed anything in. Nice try.")

        state.examples!.forEach { example in
            state.currentExample = example
            self.performBackground()
            routine()
            state.currentExample = nil
        }
    }

    func Outline(_ routine: ()->(), examples titles: [String], _ allValues: [String]...) {
        Outline(routine, examples: [titles] + allValues)
    }

    func Outline(_ routine: ()->(), _ allValues: () -> [[String]]) {
        Outline(routine, examples: allValues())
    }

    func Outline(_ routine: ()->(), examples allValues: [[String]]) {
        Examples(allValues)
        Outline(routine)
    }

    func Outline(_ routine: ()->(), _ allValues: () -> [[String: ExampleStringRepresentable]]) {
        Outline(routine, examples: allValues())
    }

    func Outline(_ routine: ()->(), examples allValues: [[String: ExampleStringRepresentable]]) {
        Examples(allValues)
        Outline(routine)
    }

    func exampleValue<T: ExampleStringRepresentable>(_ title: String) -> T? {
        let value = state.currentExample?[title]
        if let value = value as? T {
            return value
        } else if let value = value as? String {
            return T(fromMatch: value)
        }
        return nil
    }
}
