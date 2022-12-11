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
    @Published var shouldDisplayWinPanel = false
    @Published var score = Constants.StartScore
    
    private var evalPanelLastTick: Double = 0
    
    var testMode: Bool {
        return ProcessInfo.processInfo.arguments.contains("isRunningUITests")
    }
    
    // MARK: - Scoring functions
    
    /**
     Score is at the top of the screen. The best 3 scores for an installation of the game are saved in settings.
     
     A player gets score added whenever a match is made, and the "Its a match" dialog is displayed.

     Each triple is worth 3
     Each run is worth 6
     Example:

     1 of stripe orange diamonds
     2 of filled orange diamonds
     3 of outlined orange diamonds
     The 1, 2 and 3 is a run. That is 6 pts. The stripe, fill & outlined is a run, also 6 pts. The three diamonds are a triple - 3 pts, and the 3 oranges are a triple, 3 pts.

     It costs 3 points to press the deal 3 button (unless you have a set). It costs 6 points to get a hint (unless the there are no sets).
     */
    
    func calculateScore() {
        score += model.scoreForCurrentSet
    }
    
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
    
    var isWin: Bool {
        return model.playableCards.count == 0
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
    
    private var fsm: GameStateMachine!
    static private var fsmFactory = FSMFactory()
    
    static private func createModel() -> SetGameModel {
        let testMode = ProcessInfo.processInfo.arguments.contains("isRunningUITests")
        let mdl = testMode ? SetGameModel(cards: SetGameModel.fillDeck()) : SetGameModel()
        return mdl
    }
    
    static func createGame() -> SetGameViewModel {
        let fsm = GameStateMachine(withFactory: fsmFactory)
        let game = SetGameViewModel(
            model: createModel(),
            fsm: fsm)
        registerStateEvents(forGame: game)
        fsm.start()
        return game
    }
    
    init(model: SetGameModel, fsm: GameStateMachine) {
        self.model = model
        self.fsm = fsm
    }

    // - MARK: Intents from UX actions
    
    func hideHintPanel() {
        shouldDisplayHintPanel = false
    }
    
    func showHintPanel() {
        if !(model.isMatchedSet || model.matchesInPlayableCards.isEmpty) {
            if score >= Constants.CostOfHint {
                score -= Constants.CostOfHint
            } else {
                shouldDisplayWinPanel = true
                return
            }
        }
        shouldDisplayHintPanel = true
    }
    
    func hideEvaluationPanel() {
        shouldDisplayEvaluationPanel = false
        stopEvalPanelTimer()
    }
    
    func hideWinPanel() {
        shouldDisplayWinPanel = false
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
        calculateScore()
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
        model = SetGameViewModel.createModel()
        fsm = GameStateMachine(withFactory: SetGameViewModel.fsmFactory)
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
        checkForWinCondition()
    }
    
    func deselectAllSelected() {
        let cardIds = selectedCards.map(\.id)
        for cardId in cardIds {
            deselectCard(cardId: cardId)
        }
    }
    
    func checkForWinCondition() {
        if model.deckCards.count == 0 {
            if model.playableCards.count == 0 {
                // player has won the game
                shouldDisplayWinPanel = true
            } else {
                if model.matchesInPlayableCards.count == 0 {
                    // stalemate - no more matches available, and no cards to deal out
                    shouldDisplayWinPanel = true
                }
            }
        }
    }
    
    func dealThreeCards() {
        if debug {
            let cardsInDeck = model.deckCards.count
            assert(cardsInDeck >= 3)
        }
        if !(model.isMatchedSet || model.matchesInPlayableCards.isEmpty) {
            if score >= Constants.CostOfDealThree {
                score -= Constants.CostOfDealThree
            } else {
                checkForWinCondition()
                return
            }
        }
        model.dealCards(cardCount: 3)
    }
    
    struct Constants {
        static let EvalPanelDelay = 10.0 // seconds to display panel
        
        static let ScoreForTriple = 3
        static let ScoreForRun = 6
        
        static let StartScore = 100
        static let CostOfDealThree = 3
        static let CostOfHint = 6
    }
}
