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
        evaluatingStateMachine.start()
        XCTAssertEqual(evaluatingStateMachine.currentState,
                       evaluatingStateMachine.state(forClass: ThreeSelectedForEvaluation.self))
        let shouldEvaluateExpectation = XCTNSNotificationExpectation(name: .ShouldEvaluate)
        wait(for: [ shouldEvaluateExpectation ], timeout: 0.1)
    }

    func testMatchTrue_GoesTo_IsASet() throws {
        let evaluatingStateMachine = try XCTUnwrap(evalFSM)
        evaluatingStateMachine.start()
        let expectNotify = XCTNSNotificationExpectation(name: .EvaluationAcknowledged)
        let tx = evaluatingStateMachine.acceptTrigger(.MatchStatusEvaluated(isMatch: true))
        XCTAssertEqual(
            evaluatingStateMachine.currentState,
            evaluatingStateMachine.state(forClass: IsASet.self),
            "On match should transition to IsASet"
        )
        wait(for: [ expectNotify ], timeout: 0.1)
    }
    
    func testMatchFalse_GoesTo_NotASet() throws {
        let evaluatingStateMachine = try XCTUnwrap(evalFSM)
        evaluatingStateMachine.start()
        let expectNotify = XCTNSNotificationExpectation(name: .EvaluationAcknowledged)
        let tx = evaluatingStateMachine.acceptTrigger(.MatchStatusEvaluated(isMatch: false))
        XCTAssertEqual(
            evaluatingStateMachine.currentState,
            evaluatingStateMachine.state(forClass: NotASet.self),
            "On not a match, should transition to NotASet"
        )
        wait(for: [ expectNotify ], timeout: 1.0)
    }
    
    func testFromIsASet_Ack_GoesTo_AckIsASet() throws {
        let notifyExpectation = expectation(forNotification: .EvaluationCompleted, object: evalFSM!)
        evalFSM!.enter(IsASet.self)
        let tx = evalFSM!.acceptTrigger(.MatchIndicatorAcknowledged)
        XCTAssertEqual(tx, .None)
        wait(for: [ notifyExpectation ], timeout: 0.1)
        XCTAssertEqual(
            evalFSM!.currentState,
            evalFSM!.state(forClass: AcknowledgedIsASet.self))
    }
    
    func testFromNotASet_Ack_GoesTo_AckNotASet() throws {
        let notifyExpectation = expectation(forNotification: .EvaluationCompleted, object: evalFSM!)
        evalFSM!.enter(NotASet.self)
        let tx = evalFSM!.acceptTrigger(.MatchIndicatorAcknowledged)
        XCTAssertEqual(tx, .None)
        wait(for: [ notifyExpectation ], timeout: 0.1)
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: AcknowledgedNotASet.self))
    }
    
    func testFromAckIsASet_PickNotInSet_GoesTo_OnePicked() throws {
        evalFSM!.enter(AcknowledgedIsASet.self)
        let tx = evalFSM!.acceptTrigger(.CardTapped(isSelected: false, hasId: 10))
        XCTAssertEqual(tx, .SelectingOneSelected(cardId: 10))
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: OneSelectedAfterEvaluation.self))
    }

    func testFromAckIsASet_PickIsInSet_GoesTo_ZeroPicked() throws {
        evalFSM!.enter(AcknowledgedIsASet.self)
        let tx = evalFSM!.acceptTrigger(.CardTapped(isSelected: true, hasId: 10))
        XCTAssertEqual(tx, .SelectingZeroSelected)
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: ZeroSelectedAfterEvaluation.self))
    }

    func testFromAckNotASet_PickAny_GoesTo_OnePicked() throws {
        evalFSM!.enter(AcknowledgedNotASet.self)
        let tx = evalFSM!.acceptTrigger(.CardTapped(isSelected: false, hasId: 10))
        XCTAssertEqual(tx, .SelectingOneSelected(cardId: 10))
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: OneSelectedAfterEvaluation.self))
    }
}
