//
//  SetGameVM+RulesDelegate.swift
//  SetGame
//
//  Created by Sarah Smith on 30/9/2022.
//

import Foundation

extension SetGameViewModel: HierarchicalStateMachineFactory {
    func createEvaluatingFSM() -> TriggerHandler {
        return EvaluatingStateMachine()
    }
    
    func createSelectionFSM() -> TriggerHandler {
        return SelectingStateMachine()
    }
}
