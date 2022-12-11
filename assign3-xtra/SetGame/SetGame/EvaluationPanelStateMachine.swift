//
//  EvaluationPanelStateMachine.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 6/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import Foundation
import GameplayKit

class EvaluationPanelStateMachine: GKStateMachine {

    private let acknowledgeDelay: TimeInterval
    private var evaluationElapsedTime: TimeInterval

    override func update(deltaTime sec: TimeInterval) {
        evaluationElapsedTime += sec
        if evaluationElapsedTime >= acknowledgeDelay {
            if let elapsedTimeTrigger = currentState as? ElapsedTimeTriggeredHandler {
                enter(elapsedTimeTrigger.nextStateAfterTimeElapsed)
            }
        }
    }
    
    func start() {
        enter(PanelVisible.self)
    }
    
    func hidePanel() {
        enter(PanelHidden.self)
    }
    
    func resetEvaluationElapsed() {
        evaluationElapsedTime = 0.0
    }
    
    @objc
    func userDismiss(_ notify: Notification) {
        enter(PanelHidden.self)
    }
    
    private static func subscribeToTriggers(_ evaluationPanelStateMachine: EvaluationPanelStateMachine) {
        NotificationCenter.default.addObserver(
            evaluationPanelStateMachine,
            selector: #selector(userDismiss),
            name: .ShouldHideEvaluationPanel, object: nil)
    }
    
    /** Initialise an Evaluating State Machine with a time delay to wait for after showing the evaluation panel */
    init(acknowledgeDelay delay: TimeInterval = Constants.EvalPanelDelay) {
        acknowledgeDelay = delay
        evaluationElapsedTime = 0.0
        super.init(states: [
            PanelHidden(),
            PanelVisible()
        ])
        EvaluationPanelStateMachine.subscribeToTriggers(self)
    }

    struct Constants {
        /** Default amount of time in seconds to display the eval panel.  */
        static let EvalPanelDelay = 1000.0 // seconds to display panel
    }
}

protocol ElapsedTimeTriggeredHandler {
    var nextStateAfterTimeElapsed: GKState.Type { get }
}

class PanelVisible: GKState, ElapsedTimeTriggeredHandler {
    var nextStateAfterTimeElapsed: GKState.Type { PanelHidden.self }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === PanelHidden.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let evaluationPanelStateMachine = stateMachine as? EvaluationPanelStateMachine {
            evaluationPanelStateMachine.resetEvaluationElapsed()
        }
    }
}

class PanelHidden: GKState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass === PanelVisible.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState != nil {
            NotificationCenter.default.post(name: .ShouldHideEvaluationPanel, object: stateMachine)
        }
    }
}
