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

 At this point the match / no-match display is shown to the player.  The game waits for them to
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
     state "ok set" as c
     state "ok no set" as d
     note left of c
        deal 3 to replace set
     end note
     [*] --> a
     a --> b
     b --> m: match
     b --> n: no match
     m --> c: pick card
     n --> d: pick card
     c --> p: card was in set
     c --> q: card was not in set
     d --> q
     p --> [*]
     q --> [*]
 ```
*/
class EvaluatingStateMachine: GKStateMachine, TriggerHandler {
    
    var lastTappedCard: Int?
    var wasSelected: Bool?
    
    private var handlerState: EvaluatingTriggerHandler? {
        return currentState as? EvaluatingTriggerHandler
    }
    
    @discardableResult func acceptTrigger(_ trigger: InputTrigger) -> GameState.Exit {
        if let destState = handlerState?.acceptTrigger(trigger) {
            enter(destState)
        }
        if let haveExitState = currentState as? ExitState {
            return haveExitState.exitCase
        }
        return .None
    }
    
    func start() {
        enter(ThreeSelectedForEvaluation.self)
    }
    
    init() {
        super.init(states: [
            ThreeSelectedForEvaluation(),
            IsASet(), NotASet(),
            AcknowledgedIsASet(),
            AcknowledgedNotASet(),
            ZeroSelectedAfterEvaluation(),
            OneSelectedAfterEvaluation()
        ])
    }
    
    deinit {
        print("Evaluating statemachine deinit")
    }
}

protocol EvaluatingTriggerHandler {
    func acceptTrigger(_ trigger: InputTrigger) -> GKState.Type?
}

class ThreeSelectedForEvaluation: GKState, EvaluatingTriggerHandler {
    func acceptTrigger(_ trigger: InputTrigger) -> GKState.Type? {
        switch trigger {
        case .MatchStatusEvaluated(isMatch: let match):
            print("check match: \(match)")
            return match ? IsASet.self : NotASet.self
        default:
            fatalError("Evaluating/\(self) - cannot accept \(trigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === IsASet.self || stateClass === NotASet.self
    }
    
    override func didEnter(from previousState: GKState?) {
        let notify = Notification(name: .ShouldEvaluate, object: stateMachine!)
        NotificationQueue.default.enqueue(notify, postingStyle: .asap)
        print("Entered \(self)")
    }
}

class IsASet: GKState, EvaluatingTriggerHandler {
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        switch inputTrigger {
        case .MatchIndicatorAcknowledged:
            return AcknowledgedIsASet.self
        default:
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === AcknowledgedIsASet.self
    }
    
    override func didEnter(from previousState: GKState?) {
        let notify = Notification(name: .EvaluationAcknowledged, object: stateMachine!)
        NotificationQueue.default.enqueue(notify, postingStyle: .asap)
    }
}

class NotASet: GKState, EvaluatingTriggerHandler {
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        switch inputTrigger {
        case .MatchIndicatorAcknowledged:
            return AcknowledgedNotASet.self
        default:
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === AcknowledgedNotASet.self
    }
    
    override func didEnter(from previousState: GKState?) {
        let notify = Notification(name: .EvaluationAcknowledged, object: stateMachine!)
        NotificationQueue.default.enqueue(notify, postingStyle: .asap)
    }
}

class AcknowledgedIsASet: GKState, EvaluatingTriggerHandler {
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        weak var esm = stateMachine as? EvaluatingStateMachine
        switch inputTrigger {
        case .CardTapped(isSelected: let cardWasInSet, hasId: let cardId):
            esm?.wasSelected = cardWasInSet
            esm?.lastTappedCard = cardId
            return cardWasInSet ? ZeroSelectedAfterEvaluation.self : OneSelectedAfterEvaluation.self
        case .DealThreeTapped:
            let notify = Notification(name: .ShouldDealThree, object: stateMachine!)
            NotificationQueue.default.enqueue(notify, postingStyle: .asap)
            return ZeroSelectedAfterEvaluation.self
        default:
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === ZeroSelectedAfterEvaluation.self || stateClass === OneSelectedAfterEvaluation.self
    }
    
    override func didEnter(from previousState: GKState?) {
        let notify = Notification(name: .EvaluationCompleted, object: stateMachine!)
        NotificationQueue.default.enqueue(notify, postingStyle: .asap)
    }
}

class AcknowledgedNotASet: GKState, EvaluatingTriggerHandler {
    func acceptTrigger(_ inputTrigger: InputTrigger) -> GKState.Type? {
        weak var esm = stateMachine as? EvaluatingStateMachine
        switch inputTrigger {
        case .CardTapped(isSelected: let cardWasInSet, hasId: let cardId):
            esm?.wasSelected = cardWasInSet
            esm?.lastTappedCard = cardId
            return OneSelectedAfterEvaluation.self
        case .DealThreeTapped:
            let notify = Notification(name: .ShouldDealThree, object: stateMachine!)
            NotificationQueue.default.enqueue(notify, postingStyle: .asap)
            return AcknowledgedNotASet.self
        default:
            fatalError("\(self) cannot handle trigger \(inputTrigger)")
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelectedAfterEvaluation.self
    }
    
    override func didEnter(from previousState: GKState?) {
        let notify = Notification(name: .EvaluationCompleted, object: stateMachine!)
        NotificationQueue.default.enqueue(notify, postingStyle: .asap)
    }
}

class ZeroSelectedAfterEvaluation: GKState, ExitState {
    var exitCase: GameState.Exit = .SelectingZeroSelected
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}

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
