//
//  GameStateHelpers.swift
//  SetGame
//
//  Created by Sarah Smith on 16/10/2022.
//

import Foundation
import GameplayKit

struct GameState {
    static let DestinationStateKey = "DestinationStateKey"
    static let CardIndexKey = "CardIndexKey"
    static let ShouldReplaceKey = "ShouldReplaceKey"
    static let ShouldDeselectAllKey = "ShouldDeselectAllKey"
    
    enum Exit: Equatable {
        case None
        case Evaluating
        case SelectingOneSelected(cardId: Int)
        case SelectingZeroSelected
    }
}

extension Notification.Name {
    static let ShouldEvaluate = Notification.Name("ShouldEvaluate")
    static let ShouldSelectCard = Notification.Name("ShouldSelectCard")
    static let ShouldDeselectCard = Notification.Name("ShouldDeselectCard")
    static let ShouldDealThree = Notification.Name("ShouldDealThree")
    static let ShouldHideEvaluationPanel = Notification.Name("ShouldHideEvaluationPanel")
    static let ShouldClearSelection = Notification.Name("ShouldClearSelection")
}

extension Notification {
    func getCardIndex() -> Int {
        return userInfo![GameState.CardIndexKey] as! Int
    }
    func getShouldReplace() -> Bool {
        guard let shouldReplace = userInfo?[GameState.ShouldReplaceKey] as? Bool else {
            return false
        }
        return shouldReplace
    }
    func getShouldDeselectAll() -> Bool {
        guard let shouldDeselectAll = userInfo?[GameState.ShouldDeselectAllKey] as? Bool else {
            return false
        }
        return shouldDeselectAll
    }
}

/** Output the argument to stdout,  if DEBUG is a defined compile time switch, otherwise do nothing. The argument expression is not evaluated if DEBUG is not defined. */
func debugMsg(_ output: @autoclosure () -> String) {
#if DEBUG
    print("DEBUG: ", msg())
#endif
}
