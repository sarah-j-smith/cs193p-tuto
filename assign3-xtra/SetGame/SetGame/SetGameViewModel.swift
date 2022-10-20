//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation
import GameKit

class SetGameViewModel: ObservableObject {
    typealias Card = SetGameModel.Card
    
    @Published internal var model = SetGameModel()
    
    @Published var shouldDisplayEvaluationPanel = false
    
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
    
    private var evalPanelTimer: Timer?
    
    lazy private var fsm: GameStateMachine = GameStateMachine(withGameDelegate: self)
        
    // - MARK: Intents
    
    func dealThreeMorePressed() {
        fsm.acceptDealThreeTapped()
    }
    
    func cardTapped(_ cardId: Int, isSelected selected: Bool) {
        fsm.acceptCardTapped(cardId, isSelected: selected)
    }
    
    func showGameOver() {
        print("Game over")
    }
    
    func showEvaluationPanel() {
        self.shouldDisplayEvaluationPanel = true
    }
    
    func hideEvaluationPanel() {
        self.shouldDisplayEvaluationPanel = false
    }
    
    func selectCard(cardId: Int) {
#if DEBUG
        let card = self.model.dealtCards.firstIndex { $0.id == cardId }
        guard let haveCard = card else {
            assertionFailure("Tried to select invalid card")
            return
        }
        let shouldBeDeSelected = self.model.dealtCards[haveCard]
        assert(shouldBeDeSelected.selected == false)
#endif
        self.model.toggleCardSelection(cardId)
    }
    
    func deselectCard(cardId: Int) {
#if DEBUG
        let card = self.model.dealtCards.firstIndex { $0.id == cardId }
        guard let haveCard = card else {
            assertionFailure("Tried to deselect invalid card")
            return
        }
        let shouldBeSelected = self.model.dealtCards[haveCard]
        assert(shouldBeSelected.selected)
#endif
        self.model.toggleCardSelection(cardId)
    }
    
    func dealThreeCards() {
#if DEBUG
        let cardsInDeck = self.model.deckCards.count
        assert(cardsInDeck >= 3)
#endif
        self.model.dealCards(cardCount: 3)
    }
    
    func startEvalPanelTimer() {
        evalPanelTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.EvalPanelDelay,
            repeats: false) { _ in
                self.dismissEvaluationPanel()
            }
    }
    
    func dismissEvaluationPanel() {
        evalPanelTimer?.invalidate()
        evalPanelTimer = nil
    }
    
    struct Constants {
        static let EvalPanelDelay = 10.0 // seconds to display panel
    }
    
    func newGamePressed() {
        model = SetGameModel()
        fsm = GameStateMachine(withGameDelegate: self)
        fsm.start()
    }
}
