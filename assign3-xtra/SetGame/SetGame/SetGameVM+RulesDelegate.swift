//
//  SetGameVM+RulesDelegate.swift
//  SetGame
//
//  Created by Sarah Smith on 30/9/2022.
//

import Foundation


extension SetGameViewModel: CardTriggerHandlerFactory {
    func createEvaluatingFSM(withGameDataProvider gdp: GameDelegate) -> CardTriggerHandler {
        return EvaluatingStateMachine(withGameDelegate: gdp)
    }
    
    func createSelectionFSM(withGameDataProvider gdp: GameDelegate) -> CardTriggerHandler {
        return SelectingStateMachine(withDelegate: gdp)
    }
}

extension SetGameViewModel: GameDelegate {
    
    func isMatch() -> Bool {
        return self.model.isMatchedSet
    }
    
    func isDeckExhausted() -> Bool {
        return self.model.deckCards.isEmpty
    }
}
