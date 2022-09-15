//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation

class SetGameViewModel: ObservableObject {
    
    typealias Card = SetGameModel.Card
    
    @Published private var model = SetGameModel(cards: [
        Card(id: 0, shape: .Oval, color: .Green),
        Card(id: 1, shape: .Squiggle, color: .Green),
        Card(id: 2, shape: .Diamond, color: .Green),
        Card(id: 3, shape: .Squiggle, color: .Green),
    ])
    
    var cards: [ SetGameModel.Card ] {
        return model.cards
    }
}
