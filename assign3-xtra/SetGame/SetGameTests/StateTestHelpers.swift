//
//  StateTestHelpers.swift
//  SetGameTests
//
//  Created by Sarah Smith on 16/10/2022.
//

import Foundation
import GameplayKit

class MockGameDelegate: GameDelegate {
    func isMatch() -> Bool {
        return isTestMatch
    }
    
    func isDeckExhausted() -> Bool {
        return deckExhausted
    }
    
    var cards = Set<Int>()
    var cardsDealt = 0
    var isTestMatch = true
    var panelDisplayed = true
    var deckExhausted = false
    

    var evaluatingStateMachine: CardTriggerHandler?
    var selectingStateMachine: CardTriggerHandler?
}

extension MockGameDelegate: CardTriggerHandlerFactory {
    func createEvaluatingFSM(withGameDataProvider gdp: GameDelegate) -> CardTriggerHandler {
        return evaluatingStateMachine!
    }
    
    func createSelectionFSM(withGameDataProvider gdp: GameDelegate) -> CardTriggerHandler {
        return selectingStateMachine!
    }
}

class MockLowLevelStateMachine: CardTriggerHandler {
    var shouldUseWhenIdle: Bool = false
    var triggers: [ InputTrigger ] = []
    func acceptCardTappedTrigger(t inputTrigger: InputTrigger) {
        triggers.append(inputTrigger)
    }
}
