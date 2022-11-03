//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Sarah Smith on 30/9/2022.
//

import XCTest

final class GameStateMachineTests: XCTestCase {
    
    var factory: MockGameFactory!
    var fsm: GameStateMachine!
    var selectingFSM: MockLowLevelStateMachine? {
        return factory.selectingStateMachine as? MockLowLevelStateMachine
    }
    var evaluatingFSM: MockLowLevelStateMachine? {
        return factory.evaluatingStateMachine as? MockLowLevelStateMachine
    }

    override func setUpWithError() throws {
        factory = MockGameFactory()
        fsm = GameStateMachine(withFactory: factory)
        XCTAssertNotNil(fsm, "Tests setup should create FSM")
        XCTAssertNotNil(factory, "Tests setup should create rules delegate")
    }

    override func tearDownWithError() throws {
        factory = nil
        fsm = nil
    }

    func testStateMachineCreation() throws {
        let gameStateMachine = try XCTUnwrap(fsm)
        XCTAssertNil(gameStateMachine.currentState)
    }
    
    func testStart() throws {
        let gameStateMachine = try XCTUnwrap(fsm)
        gameStateMachine.start()
        XCTAssertEqual(
            gameStateMachine.currentState,
            gameStateMachine.state(forClass: Selecting.self),
            "On start Game State FSM should enter the Selecting state"
        )
        let selecting = try XCTUnwrap(
            gameStateMachine.currentState as? Selecting,
            "The current state should be a Selecting instance"
        )
        XCTAssertIdentical(
            selecting.childFSM,
            selectingFSM,
            "On entering Selecting should call factory to setup child FSM"
        )
    }
    
    func testHighLevelTransitionToEvaluating() throws {
        let gameStateMachine = try XCTUnwrap(fsm)
        gameStateMachine.start()
        factory.mockAcceptResultForSelecting(.Evaluating)
        gameStateMachine.acceptCardTapped(1, isSelected: true)
        XCTAssertEqual(
            gameStateMachine.currentState!,
            gameStateMachine.state(forClass: Evaluating.self),
            "On receiving Evaluating back from accept in Selecting moves to Evaluating"
        )
        let evaluating = try XCTUnwrap(
            gameStateMachine.currentState as? Evaluating,
            "The current state should be a Evaluating instance"
        )
        XCTAssertIdentical(
            evaluating.childFSM,
            evaluatingFSM,
            "On entering Evaluating should call factory to setup child FSM"
        )
        let selecting = try XCTUnwrap(
            gameStateMachine.state(forClass: Selecting.self),
            "Will still have selecting state instance, tho' this is not current"
        )
        XCTAssertNil(
            selecting.childFSM,
            "Selecting FSM will have had its child FSM deleted"
        )
    }
    
    func testHighLevelTransitionToSelecting() throws {
        let gameStateMachine = try XCTUnwrap(fsm)
        gameStateMachine.start()
        gameStateMachine.enter(Evaluating.self)
        
        let notifyExpectation = expectation(forNotification: .SelectionCommencing, object: gameStateMachine)
        factory.mockAcceptResultForEvaluating(.SelectingZeroSelected)
        gameStateMachine.acceptCardTapped(1, isSelected: true)
        XCTAssertEqual(
            gameStateMachine.currentState!,
            gameStateMachine.state(forClass: Selecting.self),
            "On receiving ShouldTransitionGameState in Evaluating moves to Selecting"
        )
        let selecting = try XCTUnwrap(
            gameStateMachine.currentState as? Selecting,
            "The current state should be a Evaluating instance"
        )
        XCTAssertIdentical(
            selecting.childFSM,
            selectingFSM,
            "On entering Evaluating should call factory to setup child FSM"
        )
        let evaluating = try XCTUnwrap(
            gameStateMachine.state(forClass: Evaluating.self),
            "Will still have evaluating state instance, tho' this is not current"
        )
        XCTAssertNil(
            evaluating.childFSM,
            "Evaluating FSM will have had its child FSM deleted"
        )
        wait(for: [ notifyExpectation ], timeout: 0.1)
    }
    
    func testSelectingStatePassesTriggersToLowerLevelMachine() throws {
        let gameStateMachine = try XCTUnwrap(fsm)
        gameStateMachine.start()
        gameStateMachine.acceptCardTapped(5, isSelected: false)
        gameStateMachine.acceptCardTapped(6, isSelected: true)
        gameStateMachine.acceptCardTapped(7, isSelected: false)
        gameStateMachine.acceptDealThreeTapped()
        XCTAssertEqual(
            selectingFSM!.triggers[0],
            InputTrigger.CardTapped(isSelected: false, hasId: 5))
        XCTAssertEqual(
            selectingFSM!.triggers[1],
            InputTrigger.CardTapped(isSelected: true, hasId: 6))
        XCTAssertEqual(
            selectingFSM!.triggers[2],
            InputTrigger.CardTapped(isSelected: false, hasId: 7))
        XCTAssertEqual(
            selectingFSM!.triggers[3],
            InputTrigger.DealThreeTapped)
    }
    
    func testEvaluatingStatePassesTriggersToLowerLevelMachine() throws {
        let gameStateMachine = try XCTUnwrap(fsm)
        gameStateMachine.enter(Evaluating.self)
        gameStateMachine.acceptCardTapped(5, isSelected: false)
        gameStateMachine.acceptDealThreeTapped()
        gameStateMachine.acceptAcknowledgeEval()
        gameStateMachine.acceptSetEvaluated(matchState: true)
        gameStateMachine.acceptSetEvaluated(matchState: false)
        gameStateMachine.acceptCardsExhausted()
        XCTAssertEqual(
            evaluatingFSM!.triggers[0],
            InputTrigger.CardTapped(isSelected: false, hasId: 5))
        XCTAssertEqual(
            evaluatingFSM!.triggers[1],
            InputTrigger.DealThreeTapped)
        XCTAssertEqual(
            evaluatingFSM!.triggers[2],
            InputTrigger.MatchIndicatorAcknowledged)
        XCTAssertEqual(
            evaluatingFSM!.triggers[3],
            InputTrigger.MatchStatusEvaluated(isMatch: true))
        XCTAssertEqual(
            evaluatingFSM!.triggers[4],
            InputTrigger.MatchStatusEvaluated(isMatch: false))
        XCTAssertEqual(
            evaluatingFSM!.triggers[5],
            InputTrigger.CardsExhausted)
    }
}
