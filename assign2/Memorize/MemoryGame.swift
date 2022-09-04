//
//  MemoryGame.swift
//  Memorize
//
//  Created by Sarah Smith on 25/8/2022.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    
    // Invariant condition - if this var is not-nil, then it is the only face up card
    private var indexOfOnlyFaceUpCard: Int?
    
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = Array<Card>()
        for pairIndex in 0 ..< numberOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
        cards = cards.shuffled()
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            if let potentialMatchIndex = indexOfOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                indexOfOnlyFaceUpCard = nil
            } else {
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                indexOfOnlyFaceUpCard = chosenIndex
            }
            cards[chosenIndex].isFaceUp.toggle()
        }
        print("Chose card \(card.content) - face up: \(card.isFaceUp) - matched: \(card.isMatched) - id: \(card.id)")
    }
    
    struct Card: Identifiable {
        var id: Int
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
    }
    
    enum CardColor: CaseIterable {
        case red
        case orange
        case yellow
        case blue
        case green
        case pink
        case purple
    }
    
    typealias ContentDictionary = [ String: [ CardContent ]]
    
    /// A specification for the game theme to allow customising the content elements and look
    struct Theme where CardContent: Equatable {
        let itemSet: [CardContent]
        let name: String
        let numberOfPairs: Int
        let colorForCards: CardColor

        /// Initialise a randomly generated Theme from the given content.
        /// - Parameter content: A dictionary mapping string names to arrays of content items
        init(fromNamedContentArrays content: ContentDictionary) {
            name = content.keys.randomElement()!
            numberOfPairs = min( Int.random(in: 4...25), content[name]!.count)
            colorForCards =  CardColor.allCases.randomElement()!
            let shuffledItems = content[name]!.shuffled()[0..<numberOfPairs]
            itemSet = Array<CardContent>(shuffledItems)
        }
    }
}
