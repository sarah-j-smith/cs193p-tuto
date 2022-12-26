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
