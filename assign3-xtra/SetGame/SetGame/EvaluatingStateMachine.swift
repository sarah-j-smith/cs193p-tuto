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

class EvaluatingStateMachine: GKStateMachine, CardTriggerHandler {
    
    var lastTappedCard: Int?
    var shouldUseWhenIdle: Bool = true
    
    func acceptCardTappedTrigger(t: InputTrigger) {
        switch t {
        case .CardTapped(isSelected: _, hasId: let cardId):
            lastTappedCard = cardId
        case .MatchIndicatorAcknowledged: break
        case .DealThreeTapped:
            NotificationCenter.default.post(name: .ShouldDealThree, object: self)
        }
        enter(AcknowledgedIsASet.self)
        enter(AcknowledgedNotASet.self)
    }

    weak var rsm: GameDelegate?
    
    func start() {
        enter(ThreeSelectedForEvaluation.self)
    }
    
    func evaluate() {
        enter(rsm!.isMatch() ? IsASet.self : NotASet.self)
    }
    
    init(withGameDelegate rsm: GameDelegate?) {
        super.init(states: [
            ThreeSelectedForEvaluation(),
            IsASet(), NotASet(),
            AcknowledgedIsASet(),
            AcknowledgedNotASet(),
            ZeroSelectedAfterEvaluation(),
            OneSelectedAfterEvaluation()
        ])
        self.rsm = rsm
    }
}

protocol TriggerHandlerComponent {
    func acceptTrigger(t: InputTrigger)
}

class ThreeSelectedForEvaluation: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === IsASet.self || stateClass === NotASet.self
    }
    override func didEnter(from previousState: GKState?) {
        let notify = Notification(name: .ShouldShowEvaluationPanel, object: stateMachine!)
        NotificationQueue.default.enqueue(notify, postingStyle: .whenIdle)
    }
}

class IsASet: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === AcknowledgedIsASet.self
    }
}

class NotASet: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === AcknowledgedNotASet.self
    }
}

class AcknowledgedIsASet: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === ZeroSelectedAfterEvaluation.self || stateClass === OneSelectedAfterEvaluation.self
    }
    override func didEnter(from previousState: GKState?) {
        NotificationCenter.default.post(name: .ShouldHideEvaluationPanel, object: stateMachine!)
    }
}

class AcknowledgedNotASet: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === OneSelectedAfterEvaluation.self
    }
    override func didEnter(from previousState: GKState?) {
        NotificationCenter.default.post(name: .ShouldHideEvaluationPanel, object: stateMachine!)
    }
}

class ZeroSelectedAfterEvaluation: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    override func didEnter(from previousState: GKState?) {
        NotificationCenter.default.post(
            name: .ShouldTransitionGameState,
            object: stateMachine!,
            userInfo: [
                GameState.DestinationStateKey: Selecting.self
            ]
        )
    }
}

class OneSelectedAfterEvaluation: GKState {
    var evaluatingStateMachine: EvaluatingStateMachine {
        return stateMachine as! EvaluatingStateMachine
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
    override func didEnter(from previousState: GKState?) {
        NotificationCenter.default.post(
            name: .ShouldTransitionGameState,
            object: evaluatingStateMachine,
            userInfo: [
                GameState.DestinationStateKey: Selecting.self
            ]
        )
        NotificationCenter.default.post(
            name: .ShouldSelectCard,
            object: evaluatingStateMachine,
            userInfo: [
                GameState.CardIndexKey: evaluatingStateMachine.lastTappedCard!
            ]
        )
    }
}
