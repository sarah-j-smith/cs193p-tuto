//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation
import GameKit

class SetGameViewModel: ObservableObject {
    
#if DEBUG
    let debug = true
#else
    let debug = false
#endif
    
    typealias Card = SetGameModel.Card
    
    @Published internal var model = SetGameModel()
    
    @Published var shouldDisplayEvaluationPanel = false
    
    private var evalPanelLastTick: Double = 0
    
    // MARK: - Model convenience accessors/facade
    
    var deck: [ Card ] {
        return model.deckCards
    }

    var cards: [ Card ] {
        return model.dealtCards.filter { !$0.matched }
    }
    
    var selectionCount: Int {
        return model.selectionCount
    }
    
    var selectedCards: [ Card ] {
        return model.selectedCards
    }
    
    var matchResultExplanation: String {
        return model.matchResultExplanation
    }
    
    var isSetSelected: Bool {
        selectionCount == SetGameModel.MaxSelectionCount
    }
    
    var isMatch: Bool {
        get {
            return model.isMatchedSet
        }
    }
    
    private var evalPanelTimer: Timer?
    
    // MARK: - Game State
    
    lazy private var fsm: GameStateMachine = SetGameViewModel.createFSM(forGame: self)
    
    static func createFSM(forGame game: SetGameViewModel) -> GameStateMachine {
        let fsm = GameStateMachine(withFactory: game)
        NotificationCenter.default.addObserver(
            game, selector: #selector(shouldSelectCard),
            name: .ShouldSelectCard, object: nil)
        NotificationCenter.default.addObserver(
            game, selector: #selector(shouldDeselectCard),
            name: .ShouldDeselectCard, object: nil)
        NotificationCenter.default.addObserver(
            game, selector: #selector(shouldDealThreeCards),
            name: .ShouldDealThree, object: nil)
        NotificationCenter.default.addObserver(
            game, selector: #selector(shouldEvaluate),
            name: .ShouldEvaluate, object: nil)
        NotificationCenter.default.addObserver(
            game, selector: #selector(shouldClearMatchedCards),
            name: .ShouldClearSelection, object: nil)
        NotificationCenter.default.addObserver(
            game, selector: #selector(hideEvaluationPanel),
            name: .ShouldHideEvaluationPanel, object: nil)
        return fsm
    }
    
    static func createGame() -> SetGameViewModel {
        let game = SetGameViewModel()
        let fsm = createFSM(forGame: game)
        game.fsm = fsm
        fsm.start()
        return game
    }
        
    // - MARK: Intents from UX actions
    
    func dealThreeMorePressed() {
        fsm.acceptDealThreeTapped()
    }
    
    func cardTapped(_ cardId: Int, isSelected selected: Bool) {
        fsm.acceptCardTapped(cardId, isSelected: selected)
    }
    
    func showGameOver() {
        print("Game over")
    }
    
    // - MARK: FSM output receivers
    @MainActor
    @objc func hideEvaluationPanel(_: Notification) {
        shouldDisplayEvaluationPanel = false
        stopEvalPanelTimer()
    }
    
    @MainActor
    @objc func shouldSelectCard(notifier: Notification) {
        selectCard(cardId: notifier.getCardIndex())
    }
    
    @MainActor
    @objc func shouldDeselectCard(notifier: Notification) {
        deselectCard(cardId: notifier.getCardIndex())
    }
    
    @MainActor
    @objc func shouldDealThreeCards(notifier: Notification) {
        if notifier.getShouldReplace() {
            clearMatchedCards()
        } else {
            dealThreeCards()
        }
    }
    
    @MainActor
    @objc func shouldEvaluate(notifier: Notification) {
        fsm.acceptSetEvaluated(matchState: model.isMatchedSet)
        shouldDisplayEvaluationPanel = true
        startEvalPanelTimer()
    }
    
    @MainActor
    @objc func shouldClearMatchedCards(notifier: Notification) {
        clearMatchedCards()
    }
    
    // - MARK: Game Model actuators
    
    func newGamePressed() {
        model = SetGameModel()
        fsm = SetGameViewModel.createFSM(forGame: self)
        fsm.start()
    }
    
    func startEvalPanelTimer() {
        weak var welf = self
        evalPanelLastTick = CACurrentMediaTime()
        evalPanelTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true) { timer in
                DispatchQueue.main.async {
                    if let haveSelf = welf {
                        haveSelf.fsm.update(
                            deltaTime: haveSelf.getDeltaAndUpdateEvalPanelLastTick())
                    }
                }
            }
    }
    
    private func getDeltaAndUpdateEvalPanelLastTick() -> TimeInterval {
        let updatedEvalPanelLastTick = CACurrentMediaTime()
        let delta = updatedEvalPanelLastTick - evalPanelLastTick
        evalPanelLastTick = updatedEvalPanelLastTick
        return delta
    }
    
    func stopEvalPanelTimer() {
        evalPanelTimer?.invalidate()
        evalPanelTimer = nil
    }
    
    func selectCard(cardId: Int) {
        print("### Select card \(cardId)")
        if debug {
            let card = model.dealtCards.firstIndex { $0.id == cardId }
            guard let haveCard = card else {
                assertionFailure("Tried to select invalid card")
                return
            }
            let shouldBeDeSelected = model.dealtCards[haveCard]
            assert(shouldBeDeSelected.selected == false)
        }
        model.toggleCardSelection(cardId)
        print("### DONE Select card \(cardId)")
    }
    
    func deselectCard(cardId: Int) {
        print("### deselectCard card \(cardId)")
        if debug {
            let card = model.dealtCards.firstIndex { $0.id == cardId }
            guard let haveCard = card else {
                assertionFailure("Tried to deselect invalid card")
                return
            }
            let shouldBeSelected = model.dealtCards[haveCard]
            assert(shouldBeSelected.selected)
        }
        model.toggleCardSelection(cardId)
        print("### DONE deselectCard card \(cardId)")
    }
    
    func clearMatchedCards() {
        let cardIds = selectedCards.map(\.id)
        model.replaceMatched(cardIds: cardIds)
    }
    
    func dealThreeCards() {
        if debug {
            let cardsInDeck = model.deckCards.count
            assert(cardsInDeck >= 3)
        }
        model.dealCards(cardCount: 3)
    }
    
    struct Constants {
        static let EvalPanelDelay = 10.0 // seconds to display panel
    }
}
