//
//  StateTestHelpers.swift
//  SetGameTests
//
//  Created by Sarah Smith on 16/10/2022.
//

import Foundation
import GameplayKit
import XCTest

class MockGameFactory {
    var evaluatingStateMachine: TriggerHandler?
    var selectingStateMachine: TriggerHandler?
    
    func mockAcceptResultForSelecting(_ destinationState: GameState.Exit) {
        let ssm = selectingStateMachine as! MockLowLevelStateMachine
        ssm.acceptResult = destinationState
    }
    
    func mockAcceptResultForEvaluating(_ destinationState: GameState.Exit) {
        let ssm = evaluatingStateMachine as! MockLowLevelStateMachine
        ssm.acceptResult = destinationState
    }
}

extension MockGameFactory: HierarchicalStateMachineFactory {
    func createEvaluatingFSM() -> TriggerHandler {
        let esm = MockLowLevelStateMachine()
        evaluatingStateMachine = esm
        return esm
    }
    
    func createSelectionFSM() -> TriggerHandler {
        let ssm = MockLowLevelStateMachine()
        selectingStateMachine = ssm
        return ssm
    }
}

class MockLowLevelStateMachine: TriggerHandler {
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GameState.Exit {
        triggers.append(inputTrigger)
        return acceptResult
    }
    
    var acceptResult: GameState.Exit = .None
    
    var triggers: [ InputTrigger ] = []
}

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

