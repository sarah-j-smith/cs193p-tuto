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
 */
struct SetGameModel {
    
    var cards: [ Card ]
    
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

    struct Card: Identifiable {
        let id: Int
        let shape: ShapeFeature
        let color: ColorFeature
    }
}
