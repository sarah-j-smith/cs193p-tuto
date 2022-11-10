//
//  SetGameModelTests.swift
//  CardsOfSetTests
//
//  Created by Sarah Smith on 9/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import XCTest

final class SetGameModelTests: XCTestCase {
    
    var setGameModel: SetGameModel?
    
    struct Constants {
        static let indexOfFirstUndealtCard: Int = 12
    }
    
    private let oneOfStripedPurpleDiamonds = SetGameModel.Card(id: 39, numberOfShapes: 1, shading: .StripedShading, shape: .Diamond, color: .Purple, selected: false, matched: false)
    private let threeOfOpenRedOvals = SetGameModel.Card(id: 80, numberOfShapes: 3, shading: .OpenShading, shape: .Oval, color: .Red, selected: false, matched: false)
    private let twoOfSolidGreenSquiggles = SetGameModel.Card(id: 1, numberOfShapes: 2, shading: .SolidShading, shape: .Squiggle, color: .Green, selected: false, matched: false)

    override func setUpWithError() throws {
        // Create a model with cards not shuffled, so we can use deterministic testing
        setGameModel = SetGameModel(cards: SetGameModel.fillDeck())
    }

    override func tearDownWithError() throws {
        setGameModel = nil
    }
    
    func testGameModelCreation() throws {
        let game = try XCTUnwrap(setGameModel)
        XCTAssertTrue(game.selectedCards.isEmpty)
        XCTAssertTrue(game.denominations.isEmpty)
        XCTAssertTrue(game.shapes.isEmpty)
        XCTAssertTrue(game.colors.isEmpty)
        XCTAssertEqual(game.selectionCount, 0)
        XCTAssertEqual([game.deckCards], [game.cards[ Constants.indexOfFirstUndealtCard...]])
        XCTAssertEqual([game.dealtCards], [game.cards[0..<Constants.indexOfFirstUndealtCard]])
    }
    
    func testGameFillDeck() throws {
        let game = try XCTUnwrap(setGameModel)
        XCTAssert(game.cards.contains(oneOfStripedPurpleDiamonds))
        XCTAssert(game.cards.contains(twoOfSolidGreenSquiggles))
        XCTAssert(game.cards.contains(threeOfOpenRedOvals))
        XCTAssertEqual(game.cards.count, SetGameModel.UniqueCardCount)
    }
    
    func testKnownSetMatches() throws {
        let game = SetGameModel(
            cards: [
                oneOfStripedPurpleDiamonds.selectedCopy(),
                twoOfSolidGreenSquiggles.selectedCopy(),
                threeOfOpenRedOvals.selectedCopy() ],
            indexOfFirstUndealtCard: 3
        )
        // We know a priori that the above is a set
        XCTAssert(game.isMatchedSet)
    }
    
    func testGameMatches() throws {
        var game = try XCTUnwrap(setGameModel)
        // First three cards are 1, 2 and 3 of green solid squiggles
        game.toggleCardSelection(game.cards[0].id)
        game.toggleCardSelection(game.cards[1].id)
        game.toggleCardSelection(game.cards[2].id)
        print("####", game.cards[0], game.cards[1], game.cards[2])
        XCTAssertEqual(game.selectedCards, [ game.cards[0], game.cards[1], game.cards[2] ])
        XCTAssertEqual(game.denominations, Set<Int>([1, 2, 3]))
        XCTAssertEqual(game.colors, Set<SetGameModel.ColorFeature>( [ .Green ] ))
        XCTAssertEqual(game.shadings, Set<SetGameModel.ShadingFeature>([ .SolidShading ]))
        XCTAssertEqual(game.shapes, Set<SetGameModel.ShapeFeature>([ .Squiggle ]))
        XCTAssert(game.isMatchedSet)
        let exp = "Set!"
        let got = String(game.matchResultExplanation.prefix(exp.count))
        XCTAssertEqual(exp, got)
    }
    
    func testClearCards() throws {
        var game = SetGameModel(cards: SetGameModel.fillDeck().reversed(), indexOfFirstUndealtCard: Constants.indexOfFirstUndealtCard)
        let startingDeal = [ Array( game.cards )[ 0 ..< 12 ] ]
        let threeOnDeck = [ Array( game.deckCards )[ 0 ..< 3 ] ]
        dump(startingDeal)
        XCTAssertEqual(game.dealtCards, game.cards[ 0 ..< 12 ])
        game.toggleCardSelection(game.cards[0].id)
        game.toggleCardSelection(game.cards[1].id)
        game.toggleCardSelection(game.cards[2].id)
        let cardIds = game.selectedCards.map(\.id)
        let id = SetGameModel.UniqueCardCount - 1
        XCTAssertEqual([ id, id - 1, id - 2 ], cardIds)
        game.replaceMatched(cardIds: cardIds)
        XCTAssertEqual(game.playableCards.count, 12)
        var expected = threeOnDeck
        expected.append(contentsOf: startingDeal[ 3... ])
        XCTAssertEqual(Array(arrayLiteral: game.dealtCards), expected)
    }
    
    func testGameNotMatches() throws {
        var game = try XCTUnwrap(setGameModel)
        // First three cards are 1, 2 and 3 of green solid squiggles
        game.toggleCardSelection(game.cards[0].id)
        game.toggleCardSelection(game.cards[1].id)
        game.toggleCardSelection(game.cards[5].id)
        print("####", game.cards[0], game.cards[1], game.cards[2])
        XCTAssertFalse(game.isMatchedSet)
        let exp = "Not a set"
        let got = String(game.matchResultExplanation.prefix(exp.count))
        XCTAssertEqual(exp, got)
    }

    func testMatchesInDealtCards() throws {
        let game = try XCTUnwrap(setGameModel)
        let matches = game.matchesInPlayableCards
        XCTAssert(game.checkMatch(record: matches.first!))
        XCTAssert(game.checkMatch(record: matches.last!))
        let matchCards = matches.map { game.cardsFromMatchRecord($0) }
        dump(matchCards)
        XCTAssert(matches.count > 0)
    }

    func testPerformanceExample() throws {
        let game = try XCTUnwrap(setGameModel)
        var wins: [ SetGameModel.MatchRecord ] =  []
        self.measure {
            if let p = game.matchesInPlayableCards.first {
                if game.checkMatch(record: p) {
                    wins.append(p)
                }
            }
        }
    }

}
