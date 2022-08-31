//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by Sarah Smith on 25/8/2022.
//

import SwiftUI

class EmojiMemoryGame : ObservableObject {
    
    static func createMemoryGame() -> MemoryGame<String> {
        let theme = MemoryGame<String>.Theme(fromNamedContentArrays: EmojiConstants.all())
        return MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairs) { pairIndex in
            theme.itemSet[pairIndex]
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
    
    func newGame() {
        model = EmojiMemoryGame.createMemoryGame()
    }
}
