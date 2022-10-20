//
//  RulesStateModel.swift
//  SetGame
//
//  Created by Sarah Smith on 25/9/2022.
//

import Foundation
import GameplayKit

protocol GameDelegate: AnyObject {
    func isMatch() -> Bool
    func isDeckExhausted() -> Bool
}

enum InputTrigger {
    
    /** A card with current selection status `isSelected` and with id `hasId` is tapped by the player. */
    case CardTapped(isSelected: Bool, hasId: Int)
    
    /** The player acknowledged the evaluation panel indicating whether a match was made */
    case MatchIndicatorAcknowledged
    
    /** The player tapped the deal three button*/
    case DealThreeTapped
}

extension InputTrigger: Equatable { }

extension Notification.Name {
    static let ShouldHideEvaluationPanel = Notification.Name("ShouldHideEvaluationPanel")
    static let ShouldShowEvaluationPanel = Notification.Name("ShouldShowEvaluationPanel")
    static let ShouldEndGame = Notification.Name("ShouldEndGame")
    static let SelectCard = Notification.Name("SelectCard")
}

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
    
    init(withGameDelegate rsm: CardGameStateContainer) {
        super.init(states: [
            Selecting(withDelegate: rsm),
            Evaluating(withDelegate: rsm) ])
    }

    /**
     Start this FSM by moving to the Selecting state
     */
    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(shouldTransition),
                                               name: .ShouldTransitionGameState, object: nil)
        enter(Selecting.self)
    }
    
    /** Will transition when signalled to do so by child states FSM's */
    @objc private func shouldTransition(notification: Notification) {
        print("Got notification: \(notification)")
        enter(notification.getDestinationState())
    }
    
    /** Input trigger for player tapping on a card. */
    func acceptCardTapped(_ card: Int, isSelected selected: Bool) {
        currentTriggerHandler?.acceptCardTappedTrigger(
            t: InputTrigger.CardTapped(isSelected: selected, hasId: card))
    }
    
    /** Input trigger for player tapping on "deal 3" */
    func acceptDealThreeTapped() {
        currentTriggerHandler?.acceptCardTappedTrigger(
            t: InputTrigger.DealThreeTapped)
    }

    /** Input trigger for player acknowledging the evaluation panel */
    func acceptAcknowledgeEval() {
        currentTriggerHandler?.acceptCardTappedTrigger(
            t: InputTrigger.MatchIndicatorAcknowledged)
    }
    
    private var currentTriggerHandler: CardTriggerHandler? {
        return currentState as? CardTriggerHandler
    }
}

// MARK: - States for Selecting and Evaluating

/// Entry point for the high-level state machine to pass trigger inputs down to child FSM
protocol CardTriggerHandler: AnyObject {
    func acceptCardTappedTrigger(t inputTrigger: InputTrigger)
    func start()
    var shouldUseWhenIdle: Bool { get }
}

extension CardTriggerHandler {
    func start() {}
    var shouldUseWhenIdle: Bool { return false }
}

/// Dependency injection helper for decoupling high-level state machine from lower level
protocol CardTriggerHandlerFactory {
    func createEvaluatingFSM(withGameDataProvider: GameDelegate) -> CardTriggerHandler
    
    func createSelectionFSM(withGameDataProvider: GameDelegate) -> CardTriggerHandler
}

/// Combine the dependency injection helper and game data delegation into a container
typealias CardGameStateContainer = CardTriggerHandlerFactory & GameDelegate

/**
 Base class for Selecting and Evaluation states.
 Takes triggers and delegates them to which ever child FSM is currently executing.
 */
class CardManagerState: GKState, CardTriggerHandler {    
    func acceptCardTappedTrigger(t inputTrigger: InputTrigger) {
        childFSM?.acceptCardTappedTrigger(t: inputTrigger)
    }
    
    var childFSM: CardTriggerHandler?
    weak var rsm: CardGameStateContainer?
    
    init(withDelegate rsm: CardGameStateContainer?) {
        self.rsm = rsm
    }
}

/**
 State of selecting cards to try to make a set. This state delegates most of its operations to a
 child FSM.  When the top-level FSM moves into this state a `SelectingStateMachine` is
 instantiated and all inputs are forwarded to it.  This is a facade pattern for creating a HSM.
 */
class Selecting: CardManagerState {
    override func didEnter(from previousState: GKState?) {
        let fsm = rsm?.createSelectionFSM(withGameDataProvider: rsm!)
        DispatchQueue.main.async {
            fsm?.start()
        }
        childFSM = fsm
    }
}

/** State of evaluating and displaying if a set was made. This state delegates most of its operations to a
 child FSM.  When the top-level FSM moves into this state a `EvaluatingStateMachine` is
 instantiated and all inputs are forwarded to it. */
class Evaluating: CardManagerState {
    override func didEnter(from previousState: GKState?) {
        let fsm = rsm?.createEvaluatingFSM(withGameDataProvider: rsm!)
        DispatchQueue.main.async {
            fsm?.start()
        }
        childFSM = fsm
    }
}
