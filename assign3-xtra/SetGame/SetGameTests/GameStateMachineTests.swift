//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Sarah Smith on 30/9/2022.
//

import XCTest

final class GameStateMachineTests: XCTestCase {
    
    var game: MockGameDelegate!
    var fsm: GameStateMachine!
    var selectingFSM: MockLowLevelStateMachine!
    var evaluatingFSM: MockLowLevelStateMachine!

    override func setUpWithError() throws {
        selectingFSM = MockLowLevelStateMachine()
        evaluatingFSM = MockLowLevelStateMachine()
        game = MockGameDelegate()
        fsm = GameStateMachine(withGameDelegate: game!)
        game.selectingStateMachine = selectingFSM
        game.evaluatingStateMachine = evaluatingFSM
        XCTAssertNotNil(fsm, "Tests setup should create FSM")
        XCTAssertNotNil(game, "Tests setup should create rules delegate")
    }

    override func tearDownWithError() throws {
        game = nil
        fsm = nil
        selectingFSM = nil
        evaluatingFSM = nil
    }

    func testStateMachineCreation() throws {
        XCTAssertNil(fsm!.currentState)
    }
    
    func testStart() throws {
        fsm!.start()
        XCTAssertEqual(
            fsm!.currentState,
            fsm!.state(forClass: Selecting.self),
            "On creating FSM should enter the Selecting state"
        )
        let selecting = fsm!.currentState as! Selecting
        XCTAssertIdentical(
            selecting.childFSM,
            selectingFSM,
            "On entering Selecting should call factory to setup child FSM"
        )
    }
    
    func testHighLevelTransitionToEvaluating() throws {
        fsm!.start()
        let n = Notification.Name.ShouldTransitionGameState
        NotificationCenter.default.post(name: n, object: nil, userInfo: [
            GameState.DestinationStateKey: Evaluating.self
        ])
        XCTAssertEqual(
            fsm!.currentState!,
            fsm!.state(forClass: Evaluating.self),
            "On receiving ShouldTransitionGameState in Selecting moves to Evaluating"
        )
        let evaluating = fsm!.currentState as! Evaluating
        XCTAssertIdentical(
            evaluating.childFSM,
            evaluatingFSM,
            "On entering Evaluating should call factory to setup child FSM"
        )
    }
    
    func testSelectingStatePassesTriggersToLowerLevelMachine() throws {
        fsm!.start()
        fsm!.acceptCardTapped(5, isSelected: false)
        fsm!.acceptCardTapped(6, isSelected: true)
        fsm!.acceptCardTapped(7, isSelected: false)
        fsm!.acceptDealThreeTapped()
        XCTAssertEqual(
            selectingFSM.triggers[0],
            InputTrigger.CardTapped(isSelected: false, hasId: 5))
        XCTAssertEqual(
            selectingFSM.triggers[1],
            InputTrigger.CardTapped(isSelected: true, hasId: 6))
        XCTAssertEqual(
            selectingFSM.triggers[2],
            InputTrigger.CardTapped(isSelected: false, hasId: 7))
        XCTAssertEqual(
            selectingFSM.triggers[3],
            InputTrigger.DealThreeTapped)
    }
    
    func testEvaluatingStatePassesTriggersToLowerLevelMachine() throws {
        fsm!.enter(Evaluating.self)
        fsm!.acceptCardTapped(5, isSelected: false)
        fsm!.acceptDealThreeTapped()
        fsm!.acceptAcknowledgeEval()
        XCTAssertEqual(
            evaluatingFSM.triggers[0],
            InputTrigger.CardTapped(isSelected: false, hasId: 5))
        XCTAssertEqual(
            evaluatingFSM.triggers[1],
            InputTrigger.DealThreeTapped)
        XCTAssertEqual(
            evaluatingFSM.triggers[2],
            InputTrigger.MatchIndicatorAcknowledged)
    }

}
