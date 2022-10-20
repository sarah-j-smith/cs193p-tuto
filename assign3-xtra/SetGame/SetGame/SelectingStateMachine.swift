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
class SelectingStateMachine: GKStateMachine, CardTriggerHandler {
    
    var cardJustTapped: Int?
    var shouldUseWhenIdle: Bool = true
    
    func acceptCardTappedTrigger(t: InputTrigger) {
        switch t {
        case .CardTapped(isSelected: let selected, hasId: let cardId):
            cardJustTapped = cardId
            // If the card is selected, then tapping it will deselect it
            // moving the FSM to the previous (one less selected) state
            // Tapping a card that is *not* selected moves
            // it to the next (one more selected) state
            if let tx = selected ? seq?.previousState : seq?.nextState {
                enter(tx)
                NotificationQueue.default.enqueue(
                    Notification(
                        name: selected ? .ShouldDeselectCard : .ShouldSelectCard,
                        object: self,
                        userInfo: [
                            GameState.CardIndexKey: cardId
                        ]
                    ),
                    postingStyle: .whenIdle)
            }
        case .DealThreeTapped:
            // Does not affect state, just pass through to RSM
            NotificationCenter.default.post(name: .ShouldDealThree, object: self)
        case .MatchIndicatorAcknowledged:
            fatalError("Cannot tap acknowledge match while selecting")
        }
    }
    
    private var seq: StateSequence? {
        return currentState as? StateSequence
    }
    
    func start() {
        enter(ZeroSelected.self)
    }
    
    weak var rsm: GameDelegate?
    init(withDelegate rsm: GameDelegate?) {
        super.init(states: [
            ZeroSelected(),
            OneSelected(),
            TwoSelected(),
            ThreeSelected()
        ])
        self.rsm = rsm
    }
}

protocol StateSequence {
    var nextState: GKState.Type? { get }
    var previousState: GKState.Type? { get }
}

extension StateSequence {
    var nextState: GKState.Type? { return nil }
    var previousState: GKState.Type? { return nil }
}

class ZeroSelected: GKState, StateSequence {
    var nextState: GKState.Type? = OneSelected.self
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelected.self
    }
}

class OneSelected: GKState, StateSequence {
    var nextState: GKState.Type? = TwoSelected.self
    var previousState: GKState.Type? = ZeroSelected.self
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === ZeroSelected.self || stateClass === TwoSelected.self
    }
}

class TwoSelected: GKState, StateSequence {
    var nextState: GKState.Type? = ThreeSelected.self
    var previousState: GKState.Type? = OneSelected.self
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelected.self || stateClass === ThreeSelected.self
    }
}

class ThreeSelected: GKState, StateSequence {
    var previousState: GKState.Type? = TwoSelected.self
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    override func didEnter(from previousState: GKState?) {
        print("Did enter \(self) from \(String(describing: previousState))")
        NotificationQueue.default.enqueue(
            Notification(
                name: .ShouldTransitionGameState,
                object: stateMachine!,
                userInfo: [
                    GameState.DestinationStateKey: Evaluating.self
                ]
            ),
            postingStyle: .now)
    }
}
