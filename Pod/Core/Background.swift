//
//  Background.swift
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 01/09/2018.
//

import Foundation
import XCTest

@objc protocol GherkinTestCase {
    @objc optional func Background()
}

extension XCTestCase: GherkinTestCase {
    func performBackground() {
        (self as GherkinTestCase).Background?()
    }
}
