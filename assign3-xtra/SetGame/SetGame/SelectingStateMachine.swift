//
//  SelectingStateMachine.swift
//  SetGame
//
//  Created by Sarah Smith on 29/9/2022.
//

import Foundation
import GameplayKit

// MARK: - Selection State Machine

/**
 FSM to control behaviour when the player is selecting cards to try to make a set
 
  ## Selecting Cards

  This first state covers game states while selecting cards & trying to make a set.

  These are the rules:

  5. Users must be able to select ✅ up to 3 cards by touching on them in an attempt to make a Set (i.e. 3 cards which match, per the rules of Set). It must be clearly visible to the user which cards have been selected so far.
  7. Support “deselection” ❌ by touching already-selected cards (but only if there are 1 or 2 cards (not 3) currently selected).

  ```mermaid
  stateDiagram-v2
      state "0 picked" as a
      state "1 picked" as b
      state "2 picked" as c
      state "3 picked" as d
      [*] --> a
      a --> b: ✅
      b --> a: ❌
      b --> c: ✅
      c --> b: ❌
      c --> d: ✅
      d --> [*]
  ```
 */
class SelectingStateMachine: GKStateMachine, TriggerHandler {

    var selected = false
    var cardId = 0
    
    @discardableResult func acceptTrigger(_ trigger: InputTrigger) -> GameState.Exit {
        switch trigger {
        case .CardTapped(isSelected: let selected, hasId: let cardId):
            self.selected = selected
            self.cardId = cardId
            let seq = currentState as? SelectionSequence
            if let tx = selected ? seq?.previousState : seq?.nextState {
                let ok = enter(tx)
                print("\(self) entered \(tx) - \(ok)")
            }
        case .DealThreeTapped:
            // Does not affect state, just pass through to RSM
            NotificationCenter.default.post(name: .ShouldDealThree, object: self)
        default:
            fatalError("Selecting/\(currentState?.description ?? "nil") - cannot accept \(trigger)")
        }
        guard let next = currentState as? ExitState else {
            return .None
        }
        return next.exitCase
    }
    
    func start() {
        enter(ZeroSelected.self)
    }
    
    init() {
        super.init(states: [
            ZeroSelected(),
            OneSelected(),
            TwoSelected(),
            ThreeSelected()
        ])
    }
}

protocol SelectionSequence {
    /** This is the next state that can be transitioned forwards into, from this one */
    var nextState: GKState.Type? { get }
    /** This is the previous state that can be transitioned backwards into, from this one */
    var previousState: GKState.Type? { get }
}

extension SelectionSequence {
    var nextState: GKState.Type? { nil }
    var previousState: GKState.Type? { nil }
}

class SelectionNotifier: GKState {
    override func didEnter(from previousState: GKState?) {
        if previousState == nil { return }
        if let selectingStateMachine = stateMachine as? SelectingStateMachine {
            let noti = Notification(
                name: selectingStateMachine.selected ? .ShouldDeselectCard : .ShouldSelectCard,
                object: selectingStateMachine,
                userInfo: [
                    GameState.CardIndexKey: selectingStateMachine.cardId
                ]
            )
            NotificationCenter.default.post(noti)
        } else {
            fatalError("SelectionSequence/\(self) - cannot be a state of \(stateMachine.debugDescription)")
        }
    }
}

class ZeroSelected: SelectionNotifier, SelectionSequence {
    var nextState: GKState.Type? { OneSelected.self }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelected.self
    }
}

class OneSelected: SelectionNotifier, SelectionSequence {
    var nextState: GKState.Type? { TwoSelected.self }
    var previousState: GKState.Type? { ZeroSelected.self }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === ZeroSelected.self || stateClass === TwoSelected.self
    }
}

class TwoSelected: SelectionNotifier, SelectionSequence {
    var nextState: GKState.Type? { ThreeSelected.self }
    var previousState: GKState.Type? { OneSelected.self }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelected.self || stateClass === ThreeSelected.self
    }
}

class ThreeSelected: SelectionNotifier, SelectionSequence, ExitState {
    var exitCase = GameState.Exit.Evaluating
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
