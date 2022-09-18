//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation

class SetGameViewModel: ObservableObject {
    
    typealias Card = SetGameModel.Card
    
    @Published private var model = SetGameModel()
    
    var cards: [ Card ] {
        return model.dealtCards
    }
    
    var selectionCount: Int {
        return model.selectionCount
    }
    
    // - MARK: Intents
    //
    
    func newGamePressed() {
        model = SetGameModel()
    }
    
    func dealThreeMorePressed() {
        if cards.count < SetGameModel.UniqueCardCount {
            model.dealCards(cardCount: 3)
        }
    }
    
    func cardTapped(cardId: Int) {
        print("Selected: \(cardId)")
        try! model.toggleCardSelection(cardId: cardId)
    }
}
