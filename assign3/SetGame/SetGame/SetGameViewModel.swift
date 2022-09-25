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
    
    @Published private var model = SetGameModel()
    
    @Published private var evaluationPanelDisplayed = false
    
    var shouldShowEvaluationPanel: Bool {
        return evaluationPanelDisplayed
    }
    
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
    
    var isMatch: Bool {
        return model.isMatchedSet
    }
    
    var matchResultExplanation: String {
        return model.matchResultExplanation
    }
    
    var isSetSelected: Bool {
        selectionCount == SetGameModel.MaxSelectionCount
    }
    
    private var evalPanelTimer: Timer?
    
    // - MARK: Intents
    //
    
    private func processSet(withSelectedCard card: Int? = nil) {
        let selectedIds = selectedCards.map { $0.id }
        if isMatch {
            model.acknowledgeMatch(cardIds: selectedIds)
        } else {
            var cardsToToggle = selectedIds
            if let haveCard = card {
                if let ix = cardsToToggle.firstIndex(of: haveCard) {
                    cardsToToggle.remove(at: ix)
                } else {
                    cardsToToggle.append(haveCard)
                }
            }
            for m in cardsToToggle {
                try! model.toggleCardSelection(cardId: m)
            }
        }
    }
    
    func newGamePressed() {
        model = SetGameModel()
    }
    
    func dealThreeMorePressed() {
        if isSetSelected && isMatch {
            processSet()
        } else {
            model.dealCards(cardCount: 3)
        }
    }
    
    func cardTapped(cardId: Int) {
        print("Card tapped: \(cardId)")
        if isSetSelected {
            processSet(withSelectedCard: cardId)
        } else {
            try! model.toggleCardSelection(cardId: cardId)
            if isSetSelected {
                print("After toggle - three are selected!")
                evalPanelTimer = Timer.scheduledTimer(withTimeInterval: Constants.EvalPanelDelay, repeats: false) { _ in
                    self.dismissEvaluationPanel()
                }
            }
            evaluationPanelDisplayed = isSetSelected
        }
    }
    
    func dismissEvaluationPanel() {
        evaluationPanelDisplayed = false
        evalPanelTimer?.invalidate()
        evalPanelTimer = nil
    }
    
    struct Constants {
        static let EvalPanelDelay = 10.0 // seconds to display panel
    }
}
