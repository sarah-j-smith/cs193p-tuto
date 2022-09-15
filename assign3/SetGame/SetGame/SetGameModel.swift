//
//  SetGameModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation

struct SetGameModel {
    
    var cards: [ Card ]

    struct Card: Identifiable {
        let id: Int
        let content: String
    }

}
