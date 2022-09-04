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
        return MemoryGame<String>(withTheme: theme) { pairIndex in
            theme.itemSet[pairIndex]
        }
    }

    @Published private var model = createMemoryGame()
    
    var currentThemeColor: Color {
        switch model.theme.colorForCards {
        case .blue:
            return Color.blue
        case .pink:
            return Color.pink
        case .purple:
            return Color.purple
        case .green:
            return Color.green
        case .orange:
            return Color.orange
        case .red:
            return Color.red
        case .yellow:
            return Color.yellow
        }
    }
    
    var currentTheme: MemoryGame<String>.Theme {
        return model.theme
    }
    
    var currentScore: Int? {
        return model.score
    }
    
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
