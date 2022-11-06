//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Sarah Smith on 30/9/2022.
//

import XCTest
import GameplayKit

final class EvaluatingFSMTests: XCTestCase {
    
    var game: MockGameFactory?
    var evalFSM: EvaluatingStateMachine?
    
    override func setUpWithError() throws {
        game = MockGameFactory()
        evalFSM = EvaluatingStateMachine()
        XCTAssertNotNil(evalFSM, "Tests setup should create Eval FSM")
    }

    override func tearDownWithError() throws {
        game = nil
        evalFSM = nil
    }

    func testStateMachineStart() throws {
        let evaluatingStateMachine = try XCTUnwrap(evalFSM)
        let shouldEvaluateExpectation = XCTNSNotificationExpectation(name: .ShouldEvaluate)
        evaluatingStateMachine.start()
        XCTAssertEqual(evaluatingStateMachine.currentState,
                       evaluatingStateMachine.state(forClass: ThreeSelectedForEvaluation.self))
        wait(for: [ shouldEvaluateExpectation ], timeout: 0.1)
    }

    func testMatchTrue_GoesTo_IsASet() throws {
        let evaluatingStateMachine = try XCTUnwrap(evalFSM)
        evaluatingStateMachine.start()
        let tx = evaluatingStateMachine.acceptTrigger(.MatchStatusEvaluated(isMatch: true))
        XCTAssertEqual(tx, .None)
        XCTAssertEqual(
            evaluatingStateMachine.currentState,
            evaluatingStateMachine.state(forClass: IsASet.self),
            "On match should transition to IsASet"
        )
    }
    
    func testMatchFalse_GoesTo_NotASet() throws {
        let evaluatingStateMachine = try XCTUnwrap(evalFSM)
        evaluatingStateMachine.start()
        let tx = evaluatingStateMachine.acceptTrigger(.MatchStatusEvaluated(isMatch: false))
        XCTAssertEqual(tx, .None)
        XCTAssertEqual(
            evaluatingStateMachine.currentState,
            evaluatingStateMachine.state(forClass: NotASet.self),
            "On not a match, should transition to NotASet"
        )
    }
    
    func testIsASet_Deal3_ReplacesCards() throws {
        evalFSM!.enter(IsASet.self)
        let notify = XCTNSNotificationExpectation(name: .ShouldDealThree, object: evalFSM)
        notify.handler = { (n: Notification) in
            n.getShouldReplace()
        }
        let tx = evalFSM!.acceptTrigger(.DealThreeTapped)
        XCTAssertEqual(tx, .SelectingZeroSelected)
        XCTAssertIdentical(
            evalFSM?.currentState,
            evalFSM?.state(forClass: ZeroSelectedAfterEvaluation.self))
        wait(for: [ notify ], timeout: 0.1)
    }
    
    func testNotASet_Deal3_DoesNotReplaceCards() throws {
        evalFSM!.enter(NotASet.self)
        let notify = XCTNSNotificationExpectation(name: .ShouldDealThree, object: evalFSM)
        notify.handler = { (n: Notification) in
            !n.getShouldReplace()
        }
        let tx = evalFSM!.acceptTrigger(.DealThreeTapped)
        XCTAssertEqual(tx, .SelectingZeroSelected)
        XCTAssertIdentical(
            evalFSM?.currentState,
            evalFSM?.state(forClass: ZeroSelectedAfterEvaluation.self))
        wait(for: [ notify ], timeout: 2.0)
    }
    
    func testFromAckIsASet_PickNotInSet_GoesTo_OnePicked() throws {
        evalFSM!.enter(IsASet.self)
        let tx = evalFSM!.acceptTrigger(.CardTapped(isSelected: false, hasId: 10))
        XCTAssertEqual(tx, .SelectingOneSelected(cardId: 10))
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: OneSelectedAfterEvaluation.self))
    }

    func testFromAckIsASet_PickIsInSet_GoesTo_ZeroPicked() throws {
        evalFSM!.enter(IsASet.self)
        let tx = evalFSM!.acceptTrigger(.CardTapped(isSelected: true, hasId: 10))
        XCTAssertEqual(tx, .SelectingZeroSelected)
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: ZeroSelectedAfterEvaluation.self))
    }

    func testFromAckNotASet_PickAny_GoesTo_OnePicked() throws {
        evalFSM!.enter(NotASet.self)
        let tx = evalFSM!.acceptTrigger(.CardTapped(isSelected: false, hasId: 10))
        XCTAssertEqual(tx, .SelectingOneSelected(cardId: 10))
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: OneSelectedAfterEvaluation.self))
    }
}
