//
//  RulesStateModel.swift
//  SetGame
//
//  Created by Sarah Smith on 25/9/2022.
//

import Foundation
import GameplayKit

enum InputTrigger {
    
    /** A card with current selection status `isSelected` and with id `hasId` is tapped by the player. */
    case CardTapped(isSelected: Bool, hasId: Int)
    
    /** The game rules evaluated whether a selection was a match */
    case MatchStatusEvaluated(isMatch: Bool)
    
    /** The player tapped the deal three button*/
    case DealThreeTapped
}

extension InputTrigger: Equatable { }

// MARK: - Top level State Machine

/**
 
# Design

In terms of a finite state machine, the game basically oscillates between two high level states,
and in each of those states tapping cards results in different outcomes.

Each high-level state can be modeled by a lower level finite state machine.

```mermaid
stateDiagram-v2
    state "selecting cards" as S
    state "evaluating selection" as E
    [*] --> S
    S --> E: 3 selected
    E --> S: player acknowledged
    E --> [*]: deck exhausted
```

The trigger to transition from **selecting cards** to **evaluating selection** is when the count
of selected cards reaches 3.

Once in the evaluating selection FSM, if the evaluation results in the deck being exhausted
then the game is over. Otherwise the state transitions back to card selection, after the player
acknowledges the result by tapping a card, or by hitting the deal 3 more button.

 */

class GameStateMachine: GKStateMachine {
    
    init(withFactory factory: HierarchicalStateMachineFactory) {
        super.init(states: [
            Selecting(withFactory: factory),
            Evaluating(withFactory: factory) ])
    }

    /**
     Start this FSM by moving to the Selecting state
     */
    func start() {
        enter(Selecting.self)
    }
    
    override func update(deltaTime sec: TimeInterval) {
        currentState?.update(deltaTime: sec)
    }
    
    private func maybeTransitionTopLevelState(_ tx: GameState.Exit) {
        switch tx {
        case .Evaluating:
            enter(Evaluating.self)
        case .SelectingOneSelected(cardId: let cardId):
            enter(Selecting.self)
            acceptCardTapped(cardId, isSelected: false)
        case .SelectingZeroSelected:
            enter(Selecting.self)
        default:
            // do nothing
            break
        }
    }
    
    /** Input trigger for player tapping on a card. */
    func acceptCardTapped(_ card: Int, isSelected selected: Bool) {
        if let tx = handler?.acceptTrigger(.CardTapped(isSelected: selected, hasId: card)) {
            maybeTransitionTopLevelState(tx)
        }
    }
    
    /** Input trigger for player tapping the deal 3 button */
    func acceptDealThreeTapped() {
        if let tx = handler?.acceptTrigger(.DealThreeTapped) {
            maybeTransitionTopLevelState(tx)
        }
    }
    
    /** Input trigger for the game model returning an evaluation of the set condition */
    func acceptSetEvaluated(matchState: Bool) {
        if let tx = handler?.acceptTrigger(.MatchStatusEvaluated(isMatch: matchState)) {
            maybeTransitionTopLevelState(tx)
        }
    }
    
    private var handler: TriggerHandler? {
        return currentState as? TriggerHandler
    }
}

// MARK: - States for Selecting and Evaluating

/// Enpoint for the high-level state machine to pass trigger inputs down to lower level FSM
protocol TriggerHandler: AnyObject {
    func acceptTrigger(_ : InputTrigger) -> GameState.Exit
}

/// Dependency injection helper for decoupling high-level state machine from lower level
protocol HierarchicalStateMachineFactory: AnyObject {
    func createEvaluatingFSM() -> TriggerHandler    
    func createSelectionFSM() -> TriggerHandler
}

/// Implemented by terminal states that cause the FSM to exit & signal to be garbage collected
protocol ExitState: AnyObject {
    var exitCase: GameState.Exit { get }
}

/**
 Base class for Selecting and Evaluation states.
 Takes triggers and delegates them to which ever child FSM is currently executing.
 */
class CardManagerState: GKState, TriggerHandler {
    func acceptTrigger(_ trigger: InputTrigger) -> GameState.Exit {
        childFSM?.acceptTrigger(trigger) ?? .None
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let fsm = childFSM as? GKStateMachine {
            fsm.update(deltaTime: seconds)
        }
    }
    
    var childFSM: TriggerHandler?
    weak var factory: HierarchicalStateMachineFactory?
    
    init(withFactory factory: HierarchicalStateMachineFactory?) {
        self.factory = factory
    }
}

/**
 State of selecting cards to to make a set. This state delegates most of its operations to a
 child FSM.  When the top-level FSM moves into this state a `SelectingStateMachine` is
 instantiated and all inputs are forwarded to it.  This is a facade pattern for creating a HSM.
 */
class Selecting: CardManagerState {
    override func didEnter(from previousState: GKState?) {
        childFSM = factory?.createSelectionFSM()
        let selectingStateMachine = childFSM as? SelectingStateMachine
        selectingStateMachine?.start()
    }
    override func willExit(to nextState: GKState) {
        childFSM = nil
    }
}

/** State of evaluating and displaying if a set was made. This state delegates most of its operations to a
 child FSM.  When the top-level FSM moves into this state a `EvaluatingStateMachine` is
 instantiated and all inputs are forwarded to it. */
class Evaluating: CardManagerState {
    override func didEnter(from previousState: GKState?) {
        childFSM = factory?.createEvaluatingFSM()
        let evaluatingStateMachine = childFSM as? EvaluatingStateMachine
        evaluatingStateMachine?.start()
    }
    override func willExit(to nextState: GKState) {
        childFSM = nil
    }
}
