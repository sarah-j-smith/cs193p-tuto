//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Sarah Smith on 30/9/2022.
//

import XCTest
import GameplayKit

final class SelectingFSMTests: XCTestCase {
    
    var game: MockGameDelegate?
    var selFSM: SelectingStateMachine?
    
    override func setUpWithError() throws {
        game = MockGameDelegate()
        selFSM = SelectingStateMachine(withDelegate: game)
        XCTAssertNotNil(game)
        XCTAssertNotNil(selFSM)
    }

    override func tearDownWithError() throws {
        game = nil
        selFSM = nil
    }

    func testStart() throws {
        XCTAssert(selFSM?.currentState == nil)
        selFSM?.start()
        XCTAssertEqual(selFSM!.currentState,
                       selFSM!.state(forClass: ZeroSelected.self),
                       "On start FSM should enter the ZeroSelected state"
        )
    }

    func testSelectingCardZeroToOne() {
        let notify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        notify.handler = { (n: Notification) in
            if let ix = n.userInfo?[ GameState.CardIndexKey ] as? NSNumber {
                return ix.isEqual(to: 55)
            }
            return false
        }
        selFSM?.enter(ZeroSelected.self)
        let selectingACard = InputTrigger.CardTapped(isSelected: false, hasId: 55)
        selFSM?.acceptCardTappedTrigger(t: selectingACard)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: OneSelected.self),
            "From zero selected, selecting a card should transition to one selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }
    
    func testSelectingCardOneToTwo() {
        let notify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        selFSM?.enter(OneSelected.self)
        let selectingACard = InputTrigger.CardTapped(isSelected: false, hasId: 55)
        selFSM?.acceptCardTappedTrigger(t: selectingACard)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: TwoSelected.self),
            "From one selected, selecting a card should transition to two selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }
    
    func testDeselectingCardOneToZero() {
        let notify = XCTNSNotificationExpectation(name: .ShouldDeselectCard, object: selFSM)
        selFSM?.enter(OneSelected.self)
        let deselectingACard = InputTrigger.CardTapped(isSelected: true, hasId: 55)
        selFSM?.acceptCardTappedTrigger(t: deselectingACard)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: ZeroSelected.self),
            "From one selected, selecting a card should transition to two selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }

    func testSelectingCardTwoToOne() {
        let notify = XCTNSNotificationExpectation(name: .ShouldDeselectCard, object: selFSM)
        selFSM?.enter(TwoSelected.self)
        let deselectingACard = InputTrigger.CardTapped(isSelected: true, hasId: 55)
        selFSM?.acceptCardTappedTrigger(t: deselectingACard)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: OneSelected.self),
            "From two selected, deselecting a card should transition to one selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }
    
    func testSelectingCardTwoToThreeFiresEvaluatingTransition() {
        let selectNotify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        let transitionNotify = XCTNSNotificationExpectation(name: .ShouldTransitionGameState, object: selFSM)
        transitionNotify.handler = { (n: Notification) in
            if let destState = n.userInfo?[ GameState.DestinationStateKey ] as? GKState.Type {
                return destState === Evaluating.self
            }
            return false
        }
        selFSM?.enter(TwoSelected.self)
        let selectingACard = InputTrigger.CardTapped(isSelected: false, hasId: 55)
        selFSM?.acceptCardTappedTrigger(t: selectingACard)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: ThreeSelected.self),
            "From two selected, selecting a card should transition to three selected state"
        )
        wait(for: [selectNotify, transitionNotify], timeout: 0.1 )
    }
    
    func testSelectingCardThreeNotAllowed() {
        selFSM?.enter(ThreeSelected.self)
        let deselectingACard = InputTrigger.CardTapped(isSelected: true, hasId: 55)
        selFSM?.acceptCardTappedTrigger(t: deselectingACard)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: ThreeSelected.self),
            "From three selected, deselecting a card should not transition"
        )
        let notify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        notify.isInverted = true
        wait(for: [notify], timeout: 0.1)
    }
    
    
    /**
       These are the rules:

    After 3 cards have been selected, you must indicate whether those 3 cards are a match or mismatch. You can show this any way you want (colors, borders, backgrounds, whatever). Anytime there are 3 cards currently selected, it must be clear to the user whether they are a match or not (and the cards involved in a non-matching trio must look different than the cards look when there are only 1 or 2 cards in the selection).

    When any card is touched on and there are already 3 matching Set cards selected, then ...

    as per the rules of Set, replace those 3 matching Set cards with new ones from the deck

    if the deck is empty then the space vacated by the matched cards (which cannot be replaced since there are no more cards) should be made available to the remaining cards (i.e. which may well then get bigger)

    if the touched card was not part of the matching Set, then select that card

    if the touched card was part of a matching Set, then select no card

    When any card is touched and there are already 3 non-matching Set cards selected, deselect those 3 non-matching cards and select the touched-on card (whether or not it was part of the non-matching trio of cards).
     
     */


}
