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
     Keep score in your game by penalizing 1 point for every previously seen card that is involved in a mismatch and
     giving 2 points for every match (whether or not the cards involved have been “previously seen”).
     See Hints below for a more detailed explanation. The score is allowed to be negative if the user is bad at Memorize.
     
     Hints:
     A card has “already been seen” only if it has, at some point, been face up and then is turned back face down.
     So tracking “seen” cards is probably something you’ll want to do when you turn a card that is face up to be face down.
     
     If you flipped over a 🐧 + 👻 , then flipped over a ✏ + 🏀 , then flipped over two 👻 s, your score would be 2
     because you’d have scored a match (and no penalty would be incurred for the flips involving 🐧 , ✏ or 🏀
     because they have not (yet) been involved in a mismatch, nor was the 👻 ever involved in a mismatch). If you
     then flipped over the 🐧 again + 🐼 , then flipped 🏀 + 🐧 once more, your score would drop 3 full points down
     to -1 overall because that 🐧 card had already been seen (on the very first flip) and subsequently was involved
     in two separate mismatches (scoring -1 for each mismatch) and the 🏀 was mismatched after already having
     been seen (-1). If you then flip 🐧 + the other 🐧 that you finally found, you’d get 2 points for a match and be
     back up to 1 total point.
     
     The “already been seen” concept is about specific cards that have already been seen, not emoji that have been seen.
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
    
    enum ScoreType {
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

        /**
         Initialise a randomly generated Theme from the given content.
         - Parameter fromNamedContentArrays: A dictionary mapping string names to arrays of content items
         */
        init(fromNamedContentArrays content: ContentDictionary) {
            self.init(fromNamedContentArrays: content, withPairCount: content.count)
        }
        
        /**
         Initialise a randomly generated Theme with the given number of pairs taken from the given content.
         - Parameter fromNamedContentArrays: A dictionary mapping string names to arrays of content items
         - Parameter withPairCount: Number of pairs of content items for the theme
         */
        init(fromNamedContentArrays content: ContentDictionary, withPairCount pairCount: Int) {
            name = content.keys.randomElement()!
            numberOfPairs = pairCount
            colorForCards =  CardColor.allCases.randomElement()!
            let shuffledItems = content[name]!.shuffled()[0..<numberOfPairs]
            itemSet = Array<CardContent>(shuffledItems)

        }
    }
}
