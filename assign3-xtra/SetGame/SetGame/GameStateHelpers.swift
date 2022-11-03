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
    static let GameOver = Notification.Name("GameOver")
}

extension Notification {
    func getCardIndex() -> Int {
        return userInfo![GameState.CardIndexKey] as! Int
    }
}

