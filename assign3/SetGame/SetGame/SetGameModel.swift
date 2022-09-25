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
            print("Checking for set:")
        }
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
    
    mutating func dealCards(cardCount: Int) {
        indexOfFirstUndealtCard = min(indexOfFirstUndealtCard + cardCount, SetGameModel.UniqueCardCount)
    }
    
    /**
     8. When any card is touched on and there are already 3 matching Set cards selected, then ...
         * as per the rules of Set, replace those 3 matching Set cards with new ones from the deck
         *  if the deck is empty then the space vacated by the matched cards (which cannot be replaced since there are no more
              cards) should be made available to the remaining cards (i.e. which may well then get bigger)
     */
    mutating func acknowledgeMatch(cardIds: [ Int ]) {
        var newCardsIx = indexOfFirstUndealtCard
        dealCards(cardCount: 3)
        for c in cardIds {
            if let haveCard = cards.firstIndex(where: { $0.id == c }) {
                cards[haveCard].matched = true
                cards[haveCard].selected = false
                if newCardsIx < SetGameModel.UniqueCardCount {
                    cards.swapAt(haveCard, newCardsIx)
                }
                newCardsIx += 1
            }
        }
    }
    
    mutating func toggleCardSelection(cardId: Int) throws {
        print("Toggling \(cardId)")
        if let haveCard = cards.firstIndex(where: { $0.id == cardId }) {
            cards[haveCard].selected.toggle()
            print("   toggled \(haveCard)")
            if selectionCount > SetGameModel.MaxSelectionCount {
                throw SetGameErrors.ExceededMaxSelectionCount
            }
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

