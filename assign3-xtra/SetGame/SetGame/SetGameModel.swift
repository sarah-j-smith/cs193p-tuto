//
//  SetGameModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation
import GameplayKit

/**
 The deck consists of 81 unique cards that vary in four features across three possibilities
 for each kind of feature: number of shapes (one, two, or three), shape (diamond, squiggle, oval),
 shading (solid, striped, or open), and color (red, green, or purple)
 
 Each possible combination of features (e.g. a card with three striped green diamonds)
 appears as a card precisely once in the deck.
 */
struct SetGameModel {
    
#if DEBUG
    var debug = true
#else
    var debug = false
#endif
    
    var cards: [ Card ] = fillDeck().shuffled()
    
    static let UniqueCardCount = 81
    static let NumberOfShapesMax = 3
    static let MaxSelectionCount = 3
    
    enum SetGameErrors: Error {
        case ExceededMaxSelectionCount
    }
    
    // When the game starts we have 12 cards dealt out - indexes
    // This index partitions the array of cards into two: those
    // that have been dealt out and those that have not
    // If this value is >= UniqueCardCount, then all cards are dealt
    private var indexOfFirstUndealtCard: Int = 12
    
    var selectionCount: Int {
        return selectedCards.count
    }
    
    var selectedCards: [ Card ] {
        dealtCards.filter { $0.selected }
    }
    
    /**
     In the game, certain combinations of three cards are said to make up a set. For each
     one of the four categories of features — color, number, shape, and shading — the
     three cards must display that feature as either a) all the same, or b) all different.
     */
    var isMatchedSet: Bool {
        var denominations = Set<Int>()
        var shapes = Set<ShapeFeature>()
        var colours = Set<ColorFeature>()
        var shadings = Set<ShadingFeature>()
        for c in selectedCards {
            denominations.insert(c.numberOfShapes)
            shapes.insert(c.shape)
            colours.insert(c.color)
            shadings.insert(c.shading)
        }
        if debug {
            print("Checking for set: \(selectedCards)")
            assert(selectedCards.count == 3, "Must have exactly 3 selected")
        }
        // If feature is all the same, then there is 1 kind of that feature,
        // and if the feature is all different then there is 3 kinds of that
        // feature. Therefore given 3 cards they are a set if there are either
        // 1 or 3 kinds; or they are NOT a set if there are 2 kinds (among the
        // three cards) and the ARE a set otherwise.
        if denominations.count == 2 {
            if debug {
                print("Not a set: denominations are \(denominations)")
            }
            return false
        }
        if (shapes.count == 2) {
            if debug {
                print("Not a set: shapes are \(shapes)")
            }
            return false
        }
        if (colours.count == 2) {
            if debug {
                print("Not a set: colours are \(colours)")
            }
            return false
        }
        if (shadings.count == 2) {
            if debug {
                print("Not a set: shadings are \(shadings)")
            }
        }
        if debug {
            print("Yes! Its a set")
            print("  denominations are \(denominations)")
            print("  shapes are \(shapes)")
            print("  colours are \(colours)")
            print("  shadings are \(shadings)")
        }
        return true
    }
    
    var matchResultExplanation: String {
        // try for all the same
        var denominations = Set<Int>()
        var shapes = Set<ShapeFeature>()
        var colours = Set<ColorFeature>()
        var shadings = Set<ShadingFeature>()
        for c in selectedCards {
            denominations.insert(c.numberOfShapes)
            shapes.insert(c.shape)
            colours.insert(c.color)
            shadings.insert(c.shading)
        }
        if debug {
            print("Compiling explanation for set: \(selectedCards)")
            assert(selectedCards.count == 3, "Must have exactly 3 selected")
        }
        // If feature is all the same, then there is 1 kind of that feature,
        // and if the feature is all different then there is 3 kinds of that
        // feature. Therefore given 3 cards they are a set if there are either
        // 1 or 3 kinds; or they are NOT a set if there are 2 kinds (among the
        // three cards) and the ARE a set otherwise.
        if denominations.count == 2 {
            return "Not a set: denominations are \(denominations)"
        }
        if (shapes.count == 2) {
            return "Not a set: shapes are \(shapes)"
        }
        if (colours.count == 2) {
            return "Not a set: colours are \(colours)"
        }
        if (shadings.count == 2) {
            return "Not a set: shadings are \(shadings)"
        }
        return "Set! Denominations: \(denominations), shapes: \(shapes), colours: \(colours) & shading: \(shadings)"
    }
    
    var deckCards: [ Card ] {
        return Array( cards[ indexOfFirstUndealtCard... ] )
    }
    
    var dealtCards: [ Card ] {
        return Array( cards[ 0 ..< indexOfFirstUndealtCard ] )
    }
    
    // MARK: - Mutating Funcs
    
    mutating func dealCards(cardCount: Int) {
        indexOfFirstUndealtCard = min(indexOfFirstUndealtCard + cardCount, SetGameModel.UniqueCardCount)
    }
    
    /**
     Given an array of selected card ids, which signify matched cards; deselect them, and toggle them to be matched
     (so they disappear from the display of dealt cards), and replace then with new ones from the deck, unless the deck
     is exhausted.
     */
    mutating func replaceMatched(cardIds: [ Int ]) {
        // Get the index of what will be the first newly dealt card
        var newCardsIx = indexOfFirstUndealtCard
        dealCards(cardCount: 3)
        for c in cardIds {
            if let haveCard = cards.firstIndex(where: { $0.id == c }) {
                // Deselect and hide the matched card
                cards[haveCard].selected = false
                cards[haveCard].matched = true
                // Swap the newly dealt card into the position of the matched card
                if newCardsIx < SetGameModel.UniqueCardCount {
                    cards.swapAt(haveCard, newCardsIx)
                }
                newCardsIx += 1
            }
        }
    }
    
    mutating func toggleCardSelection(_ cardId: Int) {
        if let haveCard = cards.firstIndex(where: { $0.id == cardId }) {
            print("Toggle card")
            print(haveCard)
            cards[haveCard].selected.toggle()
        }
        print("==== selected =====")
        print(selectedCards)
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

// - MARK: Debug extensions

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

