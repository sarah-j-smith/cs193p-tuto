//
//  MemoryGame.swift
//  Memorize
//
//  Created by Sarah Smith on 25/8/2022.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    var theme: Theme
    var score: Int?
    
    // Invariant condition - if this var is not-nil, then it is the only face up card
    private var indexOfOnlyFaceUpCard: Int?
    
    init(withTheme cardTheme: Theme, createCardContent: (Int) -> CardContent) {
        cards = Array<Card>()
        self.theme = cardTheme
        for pairIndex in 0 ..< theme.numberOfPairs {
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
            // If there is a face up card, and we just chose another - check for matches
            if let potentialMatchIndex = indexOfOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    updateScore(.match)
                } else {
                    updateScore(.mismatch(potentialMatchIndex, chosenIndex))
                }
                indexOfOnlyFaceUpCard = nil
                
            // No face up card, the choice indicates starting a new round of guessing
            } else {
                // Start by flipping all cards back face down
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                
                // Save a reference to the current choice
                indexOfOnlyFaceUpCard = chosenIndex
            }
            cards[chosenIndex].isFaceUp.toggle()
        }
        print("Chose card \(card.content) - face up: \(card.isFaceUp) - matched: \(card.isMatched) - id: \(card.id)")
    }
    
    /**
     Keep score by penalizing 1 point for every previously seen card that is involved in a mismatch and
     giving 2 points for every match (whether or not the cards involved have been “previously seen”).
     The score is allowed to be negative if the user is bad at Memorize.
     A card has “already been seen” only if it has, at some point, been face up and then is turned back face down.
     */
    mutating private func updateScore(_ scoreUpdate: ScoreType) {
        switch scoreUpdate {
        case .match:
            score = (score ?? 0) + 2
        case .mismatch(let choiceA, let choiceB):
            let penalty = (cards[choiceA].previouslySeen ? 1 : 0) + (cards[choiceB].previouslySeen ? 1 : 0)
            score = (score ?? 0) - penalty
            cards[choiceA].previouslySeen = true
            cards[choiceB].previouslySeen = true
        }
    }
    
    struct Card: Identifiable {
        var id: Int
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var previouslySeen: Bool = false
        var content: CardContent
    }
    
    enum ScoreType: Equatable {
        case match
        case mismatch(Int, Int)
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
        
        public enum Error: Swift.Error {
            case invalidContentArraysOrName
        }
        
        init() {
            name = "Error Game"
            numberOfPairs = 0
            colorForCards = CardColor.red
            itemSet = []
        }
        
        /**
         Initialise a Theme with the given number of pairs taken from the given content, and the given number of pairs.
         - Parameter fromNamedContentArrays: A dictionary mapping theme names to arrays of content items.
         - Parameter named: The name of the theme within the dictionary of content. If nil, a random theme will be chosen.
         - Parameter withPairCount: Number of pairs of content items for the theme, or if nil, a random number of pairs; clamped to the range 1 ... content.count
         */
        init(fromNamedContentArrays content: ContentDictionary, named: String? = nil, withPairCount pairCount: Int? = nil) {
            let nameSelected = named ?? content.keys.randomElement()
            guard let haveName = nameSelected, let contentSelected = content[haveName] else {
                self = Theme()
                return
            }
            name = haveName
            numberOfPairs = pairCount ?? Int.random(in: 1...contentSelected.count)
            colorForCards =  CardColor.allCases.randomElement()!
            let shuffledItems = content[name]!.shuffled()[0..<numberOfPairs]
            itemSet = Array<CardContent>(shuffledItems)
        }
    }
}
