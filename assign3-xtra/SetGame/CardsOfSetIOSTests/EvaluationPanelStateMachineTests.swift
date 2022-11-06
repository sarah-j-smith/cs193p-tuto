//
//  EvaluationPanelStateMachineTests.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 6/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import XCTest

final class EvaluationPanelStateMachineTests: XCTestCase {
    
    var evalPanelFSM: EvaluationPanelStateMachine?
    
    override func setUpWithError() throws {
        evalPanelFSM = EvaluationPanelStateMachine()
        XCTAssertNotNil(evalPanelFSM, "Tests setup should create Eval FSM")
    }

    override func tearDownWithError() throws {
        evalPanelFSM = nil
    }
    
    func testStart() {
        evalPanelFSM!.start()
        XCTAssertIdentical(
            evalPanelFSM!.currentState,
            evalPanelFSM!.state(forClass: PanelVisible.self))
    }

    func testFromVisible_Timeout_GoesTo_Hidden() throws {
        evalPanelFSM!.enter(PanelVisible.self)
        evalPanelFSM!.update(deltaTime: EvaluationPanelStateMachine.Constants.EvalPanelDelay)
        XCTAssertEqual(
            evalPanelFSM!.currentState,
            evalPanelFSM!.state(forClass: PanelHidden.self))
    }
    
    func testFromVisible_LessThanTimeout_Stays_Visible() throws {
        evalPanelFSM!.enter(PanelVisible.self)
        evalPanelFSM!.update(deltaTime: EvaluationPanelStateMachine.Constants.EvalPanelDelay / 2.0)
        XCTAssertEqual(
            evalPanelFSM!.currentState,
            evalPanelFSM!.state(forClass: PanelVisible.self))
    }
    
    func testFromVisible_PickCard_GoesTo_Hidden() throws {
        evalPanelFSM!.enter(PanelVisible.self)
        evalPanelFSM!.hidePanel()
        XCTAssertEqual(
            evalPanelFSM!.currentState,
            evalPanelFSM!.state(forClass: PanelHidden.self))
    }
}
