//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation

class SetGameViewModel: ObservableObject {
    
    typealias Card = SetGameModel.Card
    
    @Published private var model = SetGameModel(cards: [ Card(id: 0, content: "A"), Card(id: 1, content: "B") ])
    
    var cards: [ SetGameModel.Card ] {
        return model.cards
    }
}
