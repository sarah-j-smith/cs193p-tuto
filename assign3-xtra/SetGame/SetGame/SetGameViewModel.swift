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
    @Published var shouldDisplayHintPanel = false
    @Published var shouldDisplayAboutPanel = false
    
    private var evalPanelLastTick: Double = 0
    
    // MARK: - Model convenience accessors/facade
    
    var deck: [ Card ] {
        return Array<Card>( model.deckCards )
    }

    var cards: [ Card ] {
        return model.playableCards
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
    
    var hintStructure: (cards: [ Card ], message: String) {
        let matches = model.matchesInPlayableCards
        if let hint = matches.randomElement() {
            return (
                cards: model.cardsFromMatchRecord(hint),
                message: "The current \(cards.count) cards dealt has \(matches.count) sets to find! Here's one to get you started."
            )
        } else {
            return (
                cards: [],
                message: "The current \(cards.count) cards dealt do not have any Sets that can be made. Deal some more cards!"
            )
        }
    }
    
    private var evalPanelTimer: Timer?
    
    // MARK: - Game State
    
    static func registerStateEvents(forGame game: SetGameViewModel) {
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
            game, selector: #selector(shouldClearSelection),
            name: .ShouldClearSelection, object: nil)
        NotificationCenter.default.addObserver(
            game, selector: #selector(shouldHideEvaluationPanel),
            name: .ShouldHideEvaluationPanel, object: nil)
    }
    
    lazy private var fsm: GameStateMachine = SetGameViewModel.createFSM(forGame: self)
    
    static func createFSM(forGame game: SetGameViewModel) -> GameStateMachine {
        return GameStateMachine(withFactory: game)
    }
    
    static func createGame() -> SetGameViewModel {
        let game = SetGameViewModel()
        let fsm = createFSM(forGame: game)
        registerStateEvents(forGame: game)
        game.fsm = fsm
        fsm.start()
        return game
    }

    // - MARK: Intents from UX actions
    
    func hideHintPanel() {
        shouldDisplayHintPanel = false
    }
    
    func showHintPanel() {
        shouldDisplayHintPanel = true
    }
    
    func hideEvaluationPanel() {
        shouldDisplayEvaluationPanel = false
        stopEvalPanelTimer()
    }
    
    func showAboutPressed() {
        shouldDisplayAboutPanel = true
    }
    
    func hideAboutPanel() {
        shouldDisplayAboutPanel = false
    }
    
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
    @objc func shouldHideEvaluationPanel(_: Notification) {
        hideEvaluationPanel()
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
            // In case 3 cards are a set, deal 3 will **replace** those
            replaceSelectedCardsByDealNew()
        } else if notifier.getShouldDeselectAll() {
            deselectAllSelected()
            dealThreeCards()
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
    @objc func shouldClearSelection(notifier: Notification) {
        if notifier.getShouldDeselectAll() {
            deselectAllSelected()
        } else {
            replaceSelectedCardsByDealNew()
        }
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
        if debug {
            let cardIndex = model.playableCards.getIndexById(cardId)!
            let shouldBeDeSelected = model.playableCards[cardIndex]
            assert(shouldBeDeSelected.selected == false)
        }
        model.toggleCardSelection(cardId)
    }
    
    func deselectCard(cardId: Int) {
        if debug {
            let cardIndex = model.playableCards.getIndexById(cardId)!
            let shouldBeSelected = model.playableCards[cardIndex]
            assert(shouldBeSelected.selected)
        }
        model.toggleCardSelection(cardId)
    }
    
    func replaceSelectedCardsByDealNew() {
        let cardIds = selectedCards.map(\.id)
        model.replaceMatched(cardIds: cardIds)
    }
    
    func deselectAllSelected() {
        let cardIds = selectedCards.map(\.id)
        for cardId in cardIds {
            deselectCard(cardId: cardId)
        }
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
