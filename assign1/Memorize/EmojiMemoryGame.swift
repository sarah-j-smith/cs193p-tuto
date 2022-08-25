//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Sarah Smith on 25/8/2022.
//

import SwiftUI

class EmojiMemoryGame : ObservableObject {
    static let emojis = EmojiConstants.travel
    
    static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>(numberOfPairsOfCards: 4) { pairIndex in
            emojis[pairIndex]
        }
    }

    @Published private var model = createMemoryGame()
    
    var cards: Array<MemoryGame<String>.Card> {
        return model.cards
    }
    
    // MARK: - Intents
    
    func choose(_ card: MemoryGame<String>.Card) {
        model.choose(card)
    }
}
