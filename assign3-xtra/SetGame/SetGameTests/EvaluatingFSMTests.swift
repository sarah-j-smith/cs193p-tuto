//
//  SetGameTests.swift
//  SetGameTests
//
//  Created by Sarah Smith on 30/9/2022.
//

import XCTest
import GameplayKit

final class EvaluatingFSMTests: XCTestCase {
    
    var game: MockGameDelegate?
    var evalFSM: EvaluatingStateMachine?
    
    override func setUpWithError() throws {
        game = MockGameDelegate()
        evalFSM = EvaluatingStateMachine(withGameDelegate: game)
        XCTAssertNotNil(evalFSM, "Tests setup should create Eval FSM")
    }

    override func tearDownWithError() throws {
        game = nil
        evalFSM = nil
    }

    func testStateMachineStart() throws {
        evalFSM!.start()
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: ThreeSelectedForEvaluation.self))
    }

    func testMatchTrueGoesToIsASet() {
        evalFSM!.start()
        game!.isTestMatch = true
        evalFSM!.evaluate()
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: IsASet.self))
    }
    
    func testMatchFalseGoesToNotASet() {
        evalFSM!.start()
        game!.isTestMatch = false
        evalFSM?.evaluate()
        XCTAssertEqual(evalFSM!.currentState!,
                       evalFSM!.state(forClass: NotASet.self))
    }
}
