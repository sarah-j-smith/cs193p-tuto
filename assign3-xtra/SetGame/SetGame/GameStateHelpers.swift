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
}

extension Notification.Name {
    static let ShouldTransitionGameState = Notification.Name("ShouldTransitionGameState")
    static let ShouldSelectCard = Notification.Name("ShouldSelectCard")
    static let ShouldDeselectCard = Notification.Name("ShouldDeselectCard")
    static let ShouldDealThree = Notification.Name("ShouldDealThree")
}

extension Notification {
    func getDestinationState() -> GKState.Type {
        return userInfo![GameState.DestinationStateKey] as! GKState.Type
    }
    func getCardIndex() -> Int {
        return userInfo![GameState.CardIndexKey] as! Int
    }
}
