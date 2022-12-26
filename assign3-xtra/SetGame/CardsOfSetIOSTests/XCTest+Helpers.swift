//
//  XCTest+Helpers.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 22/12/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import Foundation
import XCTest

/// Credit: https://www.avanderlee.com/swift/nspredicate-xctestexpectations/
extension XCTestCase {
    /// Creates an expectation for monitoring the given condition.
    /// - Parameters:
    ///   - condition: The condition to evaluate to be `true`.
    ///   - description: A string to display in the test log for this expectation, to help diagnose failures.
    /// - Returns: The expectation for matching the condition.
    func expectation(for condition: @autoclosure @escaping () -> Bool, description: String = "") -> XCTestExpectation {
        let predicate = NSPredicate { _, _ in
            return condition()
        }
                
        return XCTNSPredicateExpectation(predicate: predicate, object: nil)
    }
}

