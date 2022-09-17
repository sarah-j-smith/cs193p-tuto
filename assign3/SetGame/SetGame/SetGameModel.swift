//
//  SetGameModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation

/**
 The deck consists of 81 unique cards that vary in four features across three possibilities
 for each kind of feature: number of shapes (one, two, or three), shape (diamond, squiggle, oval),
 shading (solid, striped, or open), and color (red, green, or purple)
 
 Each possible combination of features (e.g. a card with three striped green diamonds)
 appears as a card precisely once in the deck.
 */
struct SetGameModel {
    
    var cards: [ Card ] = fillDeck().shuffled()
    
    static let UniqueCardCount = 81
    static let NumberOfShapesMax = 3

    // When the game starts we have 12 cards dealt out - indexes
    // This index partitions the array of cards into two: those
    // that have been dealt out and those that have not
    // If this value is >= UniqueCardCount, then all cards are dealt
    private var indexOfFirstUndealtCard: Int = 12
    
    var deckCards: [ Card ] {
        return Array( cards[ indexOfFirstUndealtCard... ] )
    }
    
    var dealtCards: [ Card ] {
        return Array( cards[ 0 ..< indexOfFirstUndealtCard ] )
    }
    
    mutating func dealCards(cardCount: Int) {
        indexOfFirstUndealtCard += cardCount
    }
    
    mutating func toggleCardSelection(cardId: Int) {
        if let haveCard = cards.firstIndex(where: { $0.id == cardId }) {
            cards[haveCard].selected = !cards[haveCard].selected
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
                                            selected: false))
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

