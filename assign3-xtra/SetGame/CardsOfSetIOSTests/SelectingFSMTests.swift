//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Sarah Smith on 30/9/2022.
//

import XCTest
import GameplayKit

final class SelectingFSMTests: XCTestCase {
    
    var game: MockGameFactory?
    var selFSM: SelectingStateMachine?
    
    override func setUpWithError() throws {
        game = MockGameFactory()
        selFSM = SelectingStateMachine()
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
        selFSM?.start()
        let notify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        notify.handler = { (n: Notification) in
            if n.userInfo?[ GameState.CardIndexKey ] != nil {
                return n.getCardIndex() == 55
            }
            return false
        }
        let tx = selFSM?.acceptTrigger(.CardTapped(isSelected: false, hasId: 55))
        XCTAssertEqual(tx, .None)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: OneSelected.self),
            "From zero selected, selecting a card should transition to one selected state"
        )
        wait(for: [notify], timeout: 5.0)
    }
    
    func testSelectingCardOneToTwo() {
        selFSM?.enter(OneSelected.self)
        let notify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        let tx = selFSM?.acceptTrigger(.CardTapped(isSelected: false, hasId: 55))
        XCTAssertEqual(tx, .None)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: TwoSelected.self),
            "From one selected, selecting a card should transition to two selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }
    
    func testDeselectingCard_OneToZero() {
        let notify = XCTNSNotificationExpectation(name: .ShouldDeselectCard, object: selFSM)
        selFSM?.enter(OneSelected.self)
        let tx = selFSM?.acceptTrigger(.CardTapped(isSelected: true, hasId: 55))
        XCTAssertEqual(tx, .None)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: ZeroSelected.self),
            "From one selected, selecting a card should transition to two selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }

    func testDeselectingCard_TwoToOne() {
        let notify = XCTNSNotificationExpectation(name: .ShouldDeselectCard, object: selFSM)
        selFSM?.enter(TwoSelected.self)
        let tx = selFSM?.acceptTrigger(.CardTapped(isSelected: true, hasId: 55))
        XCTAssertEqual(tx, .None)
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: OneSelected.self),
            "From two selected, deselecting a card should transition to one selected state"
        )
        wait(for: [notify], timeout: 0.1)
    }
    
    func testSelectingCard_TwoTwoSelect_GoesToThreeAndFiresEvaluatingTransition() {
        let selectNotify = XCTNSNotificationExpectation(name: .ShouldSelectCard, object: selFSM)
        selFSM?.enter(TwoSelected.self)
        let tx = selFSM?.acceptTrigger(.CardTapped(isSelected: false, hasId: 55))
        XCTAssert(
            tx == .Evaluating,
            "Low level selecting FSM should return target state in evaluation FSM signalling exit"
        )
        XCTAssertIdentical(
            selFSM!.currentState,
            selFSM!.state(forClass: ThreeSelected.self),
            "From two selected, selecting a card should transition to three selected state"
        )
        wait(for: [selectNotify], timeout: 0.1 )
    }
    
    func testSelectingCardThreeNotAllowed() {
        selFSM?.enter(ThreeSelected.self)
        let _ = selFSM?.acceptTrigger(.CardTapped(isSelected: true, hasId: 55))
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
