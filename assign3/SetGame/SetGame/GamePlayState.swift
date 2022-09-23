//
//  GamePlayState.swift
//  SetGame
//
//  Created by Sarah Smith on 22/9/2022.
//

import Foundation
import GameplayKit

/**
 See the main README file for more details.
 
For card selection there are three main states and an initial null state:
 0. Initial state - no cards selected
 1. Cards are being selected (0, 1 or 2 cards are selected)
 2. A set of 3 matching as per Set rules is selected
 3. A set of 3 non-matching Set cards selected
 
 ```mermaid
 stateDiagram-v2
     state if_state <<choice>>
     state join_state_a <<join>>
     state join_state_b <<join>>
     state "0 picked" as a
     state "1 picked" as b
     state "2 picked" as c
     state "3 picked" as d
     state "is a set" as e
     state "not a set" as f
     [*] --> a
     a --> b: ✅
     b --> a: ❌
     b --> c: ✅
     c --> b: ❌
     c --> d: ✅
     d --> if_state
     if_state --> e: matches
     if_state --> f : unmatched
     e --> join_state_a
     f --> join_state_b
 ```
 
 Edge transitions:
 
 ```
 |  Trigger  |  Src state  | Dest state |
 | --------- | ----------- | ---------- |
 | select    | zero        |  one       |
 | select    | one         |  two       |
 | select    | two         |  three     |
 | deselect  | one         |  zero      |
 | deselect  | two         |  one       |
 | eval-Y    | three       |  match     |
 | eval-N    | three       |  nomatch   |
 
```
 
* You can **select a card** to go from zero -> one -> two -> three; and
* and **deselect a card** to go from one -> zero, and two -> one
* The game is **evaluated** once in the three selected state and immediately transitioned to either a "match" or "no-match" state.
*/
class GamePlayState: GKStateMachine, ObservableObject {
    
    var debug = true
    
    enum Flags: CustomDebugStringConvertible {
        /** An invalid state that is entered when the game is initialised */
        case UnknownState
        
        /** Initial state. No cards are selected, player can continue to select cards*/
        case NoCardsSelected
        
        /** 1 card is selected, player can continue to select cards*/
        case OneCardSelected
        
        /** 2 cards are selected, player can continue to select cards*/
        case TwoCardsSelected
        
        /** 3 cards are selected, selection must be evaluated as match or no-match */
        case ThreeCardsSelected
        
        /** Show the "Matched" display - a Set of 3 cards is selected that constitutes a match.   */
        case IsMatchSelection
        
        /** Show the "No match!" display - a Set of 3 cards is selected but they are non-matching cards    */
        case NotMatchSelection
    }
    
    @Published var flag: Flags = .NoCardsSelected
    
    var shouldDisplayEvaluationPanel: Bool {
        switch flag {
        case .IsMatchSelection, .NotMatchSelection, .ThreeCardsSelected:
            return true
        default:
            return false
        }
    }
    
    var deselectionEnabled: Bool {
        switch flag {
        case .OneCardSelected, .TwoCardsSelected:
            return true
        default:
            return false
        }
    }
    
    var selectionEnabled: Bool {
        switch flag {
        case .NoCardsSelected, .OneCardSelected, .TwoCardsSelected:
            return true
        default:
            return false
        }
    }
    
    func setFlag(_ flag: Flags) {
        if debug {
            print("Set flag to \(flag)")
        }
        self.flag = flag
    }
    
    // MARK: - Intents (Edge triggers)
    
    /** Increment the selected cards count, in accordance with the rules of the game */
    func selectCard() -> Void {
        if let s = currentState as? CardStates, let next = s.nextState() {
            let ok = enter(next)
            if debug {
                print("selecting card: \(ok)")
            }
        }
    }
    
    /** Decrement the selected cards count, in accordance with the rules of the game */
    func deselectCard() -> Void {
        if let s = currentState as? CardStates, let prev = s.prevState() {
            let ok = enter(prev)
            if debug {
                print("selecting card \(ok)")
            }
        }
    }
    
    /** Evaluate the win condition */
    func evaluate(isMatch: Bool) {
        enter(isMatch ? IsMatchState.self : NotMatchState.self)
    }
    
    func beginGame() {
        self.enter(UnknownState.self)
        self.enter(NoCardsSelectedState.self)
    }
    
    init() {
        super.init(states: [
            UnknownState(),
            NoCardsSelectedState(),
            OneSelectedState(),
            TwoSelectedState(),
            ThreeSelectedState(),
            IsMatchState(),
            NotMatchState()
        ])
        self.enter(NoCardsSelectedState.self)
    }
}

protocol CardStates {
    
    /** State to transition to from this one if  a card is picked that is not already selected, or nil if no such card is legal or exists */
    func nextState() -> AnyClass?
    
    /** State to transition to from this one if  a card is deselected that is already selected, or nil if no such card is legal or exists */
    func prevState() -> AnyClass?
}

extension CardStates {
    func nextState() -> AnyClass? {
        return nil
    }
    
    func prevState() -> AnyClass? {
        return nil
    }
}

///
// MARK: - Implement states for FSM
///
class UnknownState: GKState, CardStates {
    func nextState() -> AnyClass? {
        return NoCardsSelectedState.self
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NoCardsSelectedState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            if fsm.debug {
                print("* -> UnknownState")
            }
        }
    }
}

class NoCardsSelectedState: GKState, CardStates {
    func nextState() -> AnyClass? {
        return OneSelectedState.self
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == OneSelectedState.self || stateClass == UnknownState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            fsm.setFlag(.NoCardsSelected)
            if fsm.debug {
                print("* -> NoCardsSelected")
            }
        }
    }
}

class OneSelectedState: GKState, CardStates {
    func nextState() -> AnyClass? {
        return TwoSelectedState.self
    }
    
    func prevState() -> AnyClass? {
        return NoCardsSelectedState.self
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == TwoSelectedState.self || stateClass == NoCardsSelectedState.self || stateClass == UnknownState.self
    }
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            fsm.setFlag(.OneCardSelected)
            if fsm.debug {
                print("* -> OneCardSelected")
            }
        }
    }
}

class TwoSelectedState: GKState, CardStates {
    func nextState() -> AnyClass? {
        return OneSelectedState.self
    }
    
    func prevState() -> AnyClass? {
        return ThreeSelectedState.self
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == OneSelectedState.self || stateClass == ThreeSelectedState.self || stateClass == UnknownState.self
    }
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            fsm.setFlag(.TwoCardsSelected)
            if fsm.debug {
                print("* -> TwoCardsSelected")
            }
        }
    }
}

class ThreeSelectedState: GKState, CardStates {
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IsMatchState.self || stateClass == NotMatchState.self || stateClass == UnknownState.self
    }
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            fsm.setFlag(.ThreeCardsSelected)
            if fsm.debug {
                print("* -> ThreeCardsSelected")
            }
        }
    }
}

class IsMatchState: GKState, CardStates {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NoCardsSelectedState.self || stateClass == OneSelectedState.self || stateClass == UnknownState.self
    }
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            fsm.setFlag(.IsMatchSelection)
            if fsm.debug {
                print("* -> IsMatchSelection")
            }
        }
    }
}

class NotMatchState: GKState, CardStates {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == NoCardsSelectedState.self || stateClass == OneSelectedState.self || stateClass == UnknownState.self
    }
    override func didEnter(from previousState: GKState?) {
        if let fsm = stateMachine as? GamePlayState {
            fsm.setFlag(.NotMatchSelection)
            if fsm.debug {
                print("* -> NotMatchSelection")
            }
        }
    }
}

extension GamePlayState.Flags: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .UnknownState:
            return "UnknownState"
        case .NoCardsSelected:
            return "NoCardsSelected"
        case .OneCardSelected:
            return "OneCardSelected"
        case .TwoCardsSelected:
            return "TwoCardsSelected"
        case .ThreeCardsSelected:
            return "ThreeCardsSelected"
        case .IsMatchSelection:
            return "IsMatchSelection"
        case .NotMatchSelection:
            return "NotMatchSelection"
        }
    }
    
    var debugDescription: String {
        return description
    }
}
