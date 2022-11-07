//
//  EvaluatingStateMachine.swift
//  SetGame
//
//  Created by Sarah Smith on 29/9/2022.
//

import Foundation
import GameplayKit

// MARK: - Evaluation State Machine

/**
 ## 3 Selected / Match / No-match display

 At this point the match / no-match panel is shown to the player.  The game waits for them to
 acknowledge the match / no-match and tap a card to then continue playing the game.

 This second diagram covers game states once three cards are selected, inside the second of the
 two high-level states.

 These are the rules:

 6. After 3 cards have been selected, you must indicate whether those 3 cards are a match or mismatch. You can show this any way you want (colors, borders, backgrounds, whatever). Anytime there are 3 cards currently selected, it must be clear to the user whether they are a match or not (and the cards involved in a non-matching trio must look different than the cards look when there are only 1 or 2 cards in the selection).

 8. When any card is touched on and there are **already 3 matching Set cards selected**, then ...

  * as per the rules of Set, replace those 3 matching Set cards with new ones from the deck

  * if the deck is empty then the space vacated by the matched cards (which cannot be replaced since there are no more cards) should be made available to the remaining cards (i.e. which may well then get bigger)

  * if the touched card was not part of the matching Set, then **select that card**

  * if the touched card was part of a matching Set, then **select no card**

 9. When any card is touched and there are **already 3 non-matching Set cards selected**, deselect those 3 non-matching cards and select the touched-on card (whether or not it was part of the non-matching trio of cards).

 ```mermaid
 stateDiagram-v2
     state "3 picked" as a
     state "set" as m
     state "no set" as n
     state "0 picked" as p
     state "1 picked" as q
     state b <<choice>>
     [*] --> a
     a --> b
     b --> m: match
     b --> n: no match
     m --> p: pick in set, deal 3
     m --> q: pick not in set
     n --> p: pick any
     n --> q: deal 3
     p --> [*]
     q --> [*]
 ```

*/
class EvaluatingStateMachine: GKStateMachine, TriggerHandler {
    
    var lastTappedCard: Int?
    var wasSelected: Bool?
    var shouldClearCards: Bool = false
    
    private var handlerState: EvaluatingTriggerHandler? {
        return currentState as? EvaluatingTriggerHandler
    }
    
    @discardableResult func acceptTrigger(_ trigger: InputTrigger) -> GameState.Exit {
        updateCardValues(withTrigger: trigger)
        // Ask the current state to handle this trigger,
        // maybe return a state to transition to next
        if let destState = handlerState?.acceptTrigger(trigger) {
            if enter(destState) {
                if let haveExitState = currentState as? ExitState {
                    return haveExitState.exitCase
                }
            }
        }
        return .None
    }
    
    func start() {
        enter(ThreeSelectedForEvaluation.self)
    }
    
    override func update(deltaTime sec: TimeInterval) {
        currentState?.update(deltaTime: sec)
    }
    
    private func updateCardValues(withTrigger trigger: InputTrigger) {
        switch trigger {
        case .CardTapped(isSelected: let selected, hasId: let cardId):
            lastTappedCard = cardId
            wasSelected = selected
        default:
            break
        }
    }
    
    /** Initialise an Evaluating State Machine with a time delay to wait for after showing the evaluation panel */
    init() {
        super.init(states: [
            ThreeSelectedForEvaluation(),
            IsASet(), NotASet(),
            ZeroSelectedAfterEvaluation(),
            OneSelectedAfterEvaluation()
        ])
    }
}

protocol EvaluatingTriggerHandler {
    var nextEvaluationState: GKState.Type? { get }
    func acceptTrigger(_ trigger: InputTrigger) -> GKState.Type?
}

extension EvaluatingTriggerHandler {
    var nextEvaluationState: GKState.Type? { nil }
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        switch inputTrigger {
        case .CardTapped(isSelected: _, hasId: _), .DealThreeTapped:
            return nextEvaluationState
        default:
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
}

class ThreeSelectedForEvaluation: GKState, EvaluatingTriggerHandler {
    func acceptTrigger(_ trigger: InputTrigger) -> GKState.Type? {
        switch trigger {
        case .MatchStatusEvaluated(isMatch: let match):
            return match ? IsASet.self : NotASet.self
        default:
            fatalError("Evaluating/\(self) - cannot accept \(trigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === IsASet.self || stateClass === NotASet.self
    }
    
    override func didEnter(from previousState: GKState?) {
        NotificationCenter.default.post(name: .ShouldEvaluate, object: stateMachine!)
    }
}

class PanelControllerState: GKState {
    var panelState: EvaluationPanelStateMachine?
    
    override func update(deltaTime seconds: TimeInterval) {
        panelState?.update(deltaTime: seconds)
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState != nil {
            panelState = EvaluationPanelStateMachine()
            panelState?.start()
        }
    }
    
    override func willExit(to nextState: GKState) {
        panelState?.hidePanel()
        panelState = nil
    }
}

class IsASet: PanelControllerState, EvaluatingTriggerHandler {
    
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        switch inputTrigger {
        case .CardTapped(isSelected: let cardWasInSet, hasId: _):
            NotificationCenter.default.post(name: .ShouldClearSelection, object: stateMachine)
            return cardWasInSet ? ZeroSelectedAfterEvaluation.self : OneSelectedAfterEvaluation.self
        case .DealThreeTapped:
            NotificationCenter.default.post(
                name: .ShouldDealThree, object: stateMachine,
                userInfo: [ GameState.ShouldReplaceKey: true ])
            return ZeroSelectedAfterEvaluation.self
        case .MatchStatusEvaluated(isMatch: _):
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === ZeroSelectedAfterEvaluation.self || stateClass === OneSelectedAfterEvaluation.self
    }
}

class NotASet: PanelControllerState, EvaluatingTriggerHandler {
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        switch inputTrigger {
        case .CardTapped(isSelected: _, hasId: _):
            NotificationCenter.default.post(
                name: .ShouldClearSelection, object: stateMachine,
                userInfo: [ GameState.ShouldDeselectAllKey: true ])
            return OneSelectedAfterEvaluation.self
        case .DealThreeTapped:
            NotificationCenter.default.post(
                name: .ShouldDealThree, object: stateMachine,
                userInfo: [ GameState.ShouldDeselectAllKey: true ])
            return ZeroSelectedAfterEvaluation.self
        case .MatchStatusEvaluated(isMatch: _):
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelectedAfterEvaluation.self || stateClass === ZeroSelectedAfterEvaluation.self
    }
}

/** The state machine exits with Zero cards selected. Evaluation is over and this state machine will be destroyed.   */
class ZeroSelectedAfterEvaluation: GKState, ExitState {
    var exitCase: GameState.Exit = .SelectingZeroSelected
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}

/** The state machine exits with One specific cards selected. Evaluation is over and this state machine will be destroyed.   */
class OneSelectedAfterEvaluation: GKState, ExitState {
    var exitCase: GameState.Exit = .None
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    
    override func didEnter(from previousState: GKState?) {
        let esm = stateMachine as! EvaluatingStateMachine
        exitCase = .SelectingOneSelected(cardId: esm.lastTappedCard ?? 0)
    }
}
