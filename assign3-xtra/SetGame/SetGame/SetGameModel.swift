//
//  SetGameModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import GameplayKit
import Algorithms

/**
 The deck consists of 81 unique cards that vary in four features across three possibilities
 for each kind of feature: number of shapes (one, two, or three), shape (diamond, squiggle, oval),
 shading (solid, striped, or open), and color (red, green, or purple)
 
 Each possible combination of features (e.g. a card with three striped green diamonds)
 appears as a card precisely once in the deck.
 */
struct SetGameModel {
    
    struct Constants {
        static let indexOfFirstUndealtCard: Int = 12
    }
    
    /** All of the set game cards - the universe of Set game cards including dealt out, matched/removed and in the deck */
    var cards: [ Card ] = fillDeck().shuffled()
    
    static let UniqueCardCount = 81
    static let NumberOfShapesMax = 3
    static let MaxSelectionCount = 3
    
    
    /**
     All cards that have not been dealt out.  */
    var deckCards: [ Card ] {
        return Array( cards[ indexOfFirstUndealtCard... ] )
    }
    
    /**
     All cards that have been dealt out.  Includes cards marked as matched.
     Filter these out to find cards that should be visible/playable . */
    var dealtCards:  [ Card ] {
        return Array( cards[ 0 ..< indexOfFirstUndealtCard ])
    }
    
    /** All cards that have been dealt out that still remain unmatched. */
    var playableCards:  [ Card ] {
        return dealtCards.filter { !$0.matched }
    }
    
    // When the game starts we have 12 cards dealt out - indexes
    // This index partitions the array of cards into two: those
    // that have been dealt out and those that have not
    // If this value is >= UniqueCardCount, then all cards are dealt
    private var indexOfFirstUndealtCard: Int = 12
    
    init(cards: [Card] = SetGameModel.fillDeck().shuffled(), indexOfFirstUndealtCard: Int = SetGameModel.Constants.indexOfFirstUndealtCard) {
        self.cards = cards
        self.indexOfFirstUndealtCard = indexOfFirstUndealtCard
    }
    
    var selectionCount: Int {
        return selectedCards.count
    }
    
    // MARK: - Identifying matched Set of cards
    
    /** Cards currently selected by the player.  These can only be dealt non-matched cards.  */
    var selectedCards: [ Card ] {
        playableCards.filter { $0.selected }
    }
    
    var denominations: Set<Int> {
        Set<Int>( selectedCards.map(\.numberOfShapes) )
    }
    
    var shapes: Set<ShapeFeature> {
        Set<ShapeFeature>( selectedCards.map(\.shape) )
    }
    
    var colors: Set<ColorFeature> {
        Set<ColorFeature>( selectedCards.map(\.color) )
    }
    
    var shadings: Set<ShadingFeature> {
        Set<ShadingFeature>( selectedCards.map(\.shading) )
    }
    
    /**
     Each triple is worth 3
     Each run is worth 6
     Example:

     1 of stripe orange diamonds
     2 of filled orange diamonds
     3 of outlined orange diamonds
     The 1, 2 and 3 is a run. That is 6 pts. The stripe, fill & outlined is a run, also 6 pts. The three diamonds are a triple - 3 pts, and the 3 oranges are a triple, 3 pts.
     */
    var scoreForCurrentSet: Int {
        if !isMatchedSet { return 0 }
        return (denominations.count == 1 ? 3 : 6) + (shapes.count == 1 ? 3 : 6) + (colors.count == 1 ? 3 : 6) + (shadings.count == 1 ? 3 : 6)
    }
    
    /**
     True, if the currently selected cards are a match under the rules of Set.
     
     In the game of Set, certain combinations of three cards are said to match. For each
     one of the four categories of features — color, number, shape, and shading — the
     three cards must have that feature as either a) all the same, or b) all different.
     */
    var isMatchedSet: Bool {
        if (selectedCards.count != 3) { return false }
        // If feature is all the same, then there is 1 kind of that feature,
        // and if the feature is all different then there is 3 kinds of that
        // feature. Therefore given 3 cards (precondition) they are a set if
        // there are either 1 or 3 kinds; or they are NOT a set if there are
        // 2 kinds (among the three cards) and they ARE a set otherwise.
        if denominations.count == 2 { return false }
        if (shapes.count == 2) { return false }
        if (colors.count == 2) { return false }
        if (shadings.count == 2) { return false }
        return true
    }
    
    /**
     A string describing if the 3 currently selected cards are a match under the rules of Set.
     
     The string return provides this description of whether for each
     one of the four categories of features — color, number, shape, and shading — the
     three cards must have that feature as either a) all the same, or b) all different.

     - Precondition: must have exactly 3 cards selected before calling this property.
     */
    var matchResultExplanation: String {
        if (selectedCards.count != 3) { return "Not a set: must have 3 cards selected" }
        // See isMatchedSet above for this logic
        if denominations.count == 2 {
            return "Not a set: denominations are \(denominations)"
        }
        if (shapes.count == 2) {
            return "Not a set: shapes are \(shapes)"
        }
        if (colors.count == 2) {
            return "Not a set: colours are \(colors)"
        }
        if (shadings.count == 2) {
            return "Not a set: shadings are \(shadings)"
        }
        let denomScore = (denominations.count == 1 ? 3 : 6)
        let shapeScore = (shapes.count == 1 ? 3 : 6)
        let colorsScore = (colors.count == 1 ? 3 : 6)
        let shadingsScore = (shadings.count == 1 ? 3 : 6)

        let denomExplainer = (denominations.count == 1 ? "Triple:" : "Run:") + " \(denominations.description) [\(denomScore)pts]"
        let shapesExplainer = (shapes.count == 1 ? "Triple:" : "Run:") + " \(shapes.description) [\(shapeScore)pts]"
        let colorsExplainer = (colors.count == 1 ? "Triple:" : "Run:") + " \(colors.description) [\(colorsScore)pts]"
        let shadingExplainer = (shadings.count == 1 ? "Triple:" : "Run:") + " \(shadings.description) [\(shadingsScore)pts]"
        return "Set! \(denomExplainer); \(shapesExplainer); \(colorsExplainer); \(shadingExplainer)"
    }

    
    // MARK: - Finding Matches for Hints
    
    /** A set of 3 indexes in to the array of playable cards, that might be a match (or not a match).  */
    typealias MatchRecord = ( Int, Int, Int )
    
    /** Transform a `MatchRecord` into an array of `Card`
     @param: 
     */
    func cardsFromMatchRecord(_ record: MatchRecord) -> [ Card ] {
        return [ playableCards[record.0], playableCards[record.1], playableCards[record.2] ]
    }
    
    func checkMatch(record: MatchRecord) -> Bool {
        let cardsRecord = cardsFromMatchRecord(record)
        if Set( cardsRecord.map(\.numberOfShapes) ).count == 2 { return false }
        if Set( cardsRecord.map(\.shape) ).count == 2 { return false }
        if Set( cardsRecord.map(\.color) ).count == 2 { return false }
        return Set( cardsRecord.map(\.shading) ).count != 2
    }
    
    var matchesInPlayableCards: [ MatchRecord ] {
        var matches: [ MatchRecord ] = []
        let playableIndexes = Array<Int>( playableCards.indices )
        let combinations = playableIndexes.combinations(ofCount: 3)
        for p in combinations {
            let s = ( p[0], p[1], p[2] )
            if checkMatch(record: s) {
                matches.append(s)
            }
        }
        return matches
    }
    
    // MARK: - Mutating Funcs
    
    mutating func dealCards(cardCount: Int) {
        indexOfFirstUndealtCard = min(indexOfFirstUndealtCard + cardCount, cards.count)
    }
    
    /**
     Given an array of selected card ids, which signify matched cards; deselect them, and toggle them to be matched
     (so they disappear from the display of dealt cards), and replace then with new ones from the deck, unless the deck
     is exhausted.
     */
    mutating func replaceMatched(cardIds: [ Int ]) {
        // Get the index of what will be the first newly dealt card
        var newCardsIx = indexOfFirstUndealtCard
        let cardCount = cards.count
        dealCards(cardCount: 3)
        for c in cardIds {
            if let haveCard = cards.getIndexById(c) {
                // Deselect and hide the matched card
                cards[haveCard].selected = false
                cards[haveCard].matched = true
                // Swap the newly dealt card into the position of the matched card
                if newCardsIx < cardCount {
                    cards.swapAt(haveCard, newCardsIx)
                }
                newCardsIx += 1
            }
        }
    }
    
    mutating func toggleCardSelection(_ cardId: Int) {
        if let haveCard = cards.getIndexById(cardId) {
            cards[haveCard].selected.toggle()
        }
    }
    
    enum ShapeFeature {
        case Diamond
        case Squiggle
        case Oval
    }
    
    enum ColorFeature {
        case Red
        case Green
        case Purple
    }
    
    enum ShadingFeature {
        case SolidShading
        case StripedShading
        case OpenShading
    }
    
    struct Card: Identifiable {
        let id: Int
        let numberOfShapes: Int
        let shading: ShadingFeature
        let shape: ShapeFeature
        let color: ColorFeature
        var selected: Bool
        var matched: Bool
        var newlyPlaced: Bool = true
    }
    
    static func dummyCards(amount: Int) -> [ Card ] {
        return ( 0 ..< amount ).map { ix in
            Card(id: ix + 100, numberOfShapes: 0, shading: .OpenShading, shape: .Diamond, color: .Green, selected: false, matched: false)
        }
    }
    
    static func fillDeck() -> [ Card ] {
        var newDeck: [ Card ] = []
        var cardIndex = 0
        for shapeFeature: ShapeFeature in [ .Squiggle, .Diamond, .Oval ] {
            for colorFeature: ColorFeature in [ .Green, .Purple, .Red ] {
                for shadingFeature: ShadingFeature in [ .SolidShading, .StripedShading, .OpenShading ] {
                    for numShapes in 1...NumberOfShapesMax {
                        newDeck.append(Card(id: cardIndex,
                                            numberOfShapes: numShapes,
                                            shading: shadingFeature, shape: shapeFeature, color: colorFeature,
                                            selected: false,
                                            matched: false))
                        cardIndex += 1
                    }
                }
            }
        }
        assert(newDeck.count == UniqueCardCount)
        assert(cardIndex == UniqueCardCount)
        return newDeck
    }
}

// - MARK: Collection extensions

extension Array<SetGameModel.Card> {
    
    /** Get the index in to the cards array of the card with the given `cardId` */
    func getIndexById(_ cardId: Int) -> Int? {
        return self.firstIndex(where: { $0.id == cardId })
    }
}

extension ArraySlice<SetGameModel.Card> {

    /** Get the index in to the cards array of the card with the given `cardId` */
    func getIndexById(_ cardId: Int) -> Int? {
        return self.firstIndex(where: { $0.id == cardId })
    }
}

extension SetGameModel.Card {
    func selectedCopy() -> SetGameModel.Card {
        return SetGameModel.Card(id: self.id, numberOfShapes: self.numberOfShapes, shading: self.shading, shape: self.shape, color: self.color, selected: true, matched: self.matched)
    }
}

// - MARK: Debug & testing extensions

extension SetGameModel.Card: Equatable, Hashable {
    static func == (lhs: SetGameModel.Card, rhs: SetGameModel.Card) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension SetGameModel.ShapeFeature: CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        switch self {
        case .Diamond:
            return "Diamond"
        case .Squiggle:
            return "Squiggle"
        case .Oval:
            return "Oval"
        }
    }
    
    var debugDescription: String {
        return description
    }
}

extension SetGameModel.ColorFeature: CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        switch self {
        case .Red:
            return "Red"
        case .Purple:
            return "Purple"
        case .Green:
            return "Green"
        }
    }
    
    var debugDescription: String {
        return description
    }
}

extension SetGameModel.ShadingFeature: CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        switch self {
        case .OpenShading:
            return "Outline"
        case .StripedShading:
            return "Striped"
        case .SolidShading:
            return "Solid"
        }
    }
    
    var debugDescription: String {
        return description
    }
}

extension SetGameModel.Card: CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        let maybePlural = numberOfShapes > 1 ? "s" : ""
        return "Id: \(id) - \(numberOfShapes) of \(color) \(shading) \(shape)\(maybePlural)\n"
    }
    
    var debugDescription: String {
        return description
    }
}

