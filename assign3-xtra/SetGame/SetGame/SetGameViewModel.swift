//
//  SetGameViewModel.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import Foundation
import GameKit


fileprivate func calculateNewHintStructure(on modelCopy: SetGameModel) -> SetGameViewModel.HintStructure {
    let matches = modelCopy.matchesInPlayableCards
    let cardCount = modelCopy.playableCards.count
    let updatedHint: SetGameViewModel.HintStructure
    if let hint = matches.randomElement() {
        updatedHint = (
            cards: modelCopy.cardsFromMatchRecord(hint),
            message: "The current \(cardCount) cards dealt has \(matches.count) sets to find! Here's one to get you started."
        )
    } else {
        updatedHint = (
            cards: [],
            message: "The current \(cardCount) cards dealt do not have any Sets that can be made. Deal some more cards!"
        )
    }
    return updatedHint
}

final class SetGameViewModel: ObservableObject {

#if DEBUG
    let debug = true
#else
    let debug = false
#endif
    
    typealias Card = SetGameModel.Card
    typealias HintStructure = (cards: [ Card ], message: String)
    
    @Published internal var model = SetGameModel()
    
    @Published var shouldDisplayEvaluationPanel = false
    @Published var shouldDisplayHintPanel = false
    @Published var shouldDisplayAboutPanel = false
    @Published var shouldDisplayWinPanel = false
    @Published var score = Constants.StartScore
    @Published var isUpdatingMatches = false
    
    private let scoresRepository = ScoresRepository()
    
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
        scoresRepository.setScore(score)
    }
    
    // MARK: - Model convenience accessors/facade
    
    private let dummyCards = SetGameModel.dummyCards(amount: 12)
    
    var dummys: [ Card ] {
        if model.playableCards.count >= 12 {
            return []
        }
        let dummyCount = 12 - model.playableCards.count
        return Array<Card>( dummyCards[ 0 ..< dummyCount ])
    }
    
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
    
    private func checkForWinCondition() {
        if model.deckCards.count == 0 {
            if model.playableCards.count == 0 {
                // player has won the game
                shouldDisplayWinPanel = true
            } else {
                // check occurs in dealThreeCards which is disabled when updating matches
                assert(!isUpdatingMatches)
                if hintStructure.cards.count == 0 {
                    // stalemate - no more matches available, and no cards to deal out
                    shouldDisplayWinPanel = true
                }
            }
        }
    }
    
    private var _hintStructure: HintStructure?
    var hintStructure: HintStructure {
        return _hintStructure ?? (cards: [], message: "")
    }
    
    func updateHintStructure() {
        print(">>> updateHintStructure")
        let timeNow = CACurrentMediaTime()
        if isUpdatingMatches { return }
        _hintStructure = nil
        self.isUpdatingMatches = true
        DispatchQueue.global(qos: .userInitiated).async {
            // Work on a copy of the actual model - do in background as this is expensive
            // computation that grows as the number of cards in the tableau
            let result = calculateNewHintStructure(on: self.model)
            DispatchQueue.main.async {
                print("   >> updating isUpdatingMatches flag")
                self._hintStructure = result
                self.isUpdatingMatches = false
                print("   elapsed time: \(CACurrentMediaTime() - timeNow)")
            }
        }
        print("<<< updateHintStructure")
    }
    
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
        let useShortDeck = ProcessInfo.processInfo.arguments.contains("useShortDeck")
        if useShortDeck {
            let testDeck = Array(SetGameModel.fillDeck().prefix(18))
            return testMode ? SetGameModel(cards: testDeck) : SetGameModel(cards: testDeck.shuffled())
        } else {
            return testMode ? SetGameModel(cards: SetGameModel.fillDeck()) : SetGameModel()
        }
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
    @objc func shouldHideEvaluationPanel(_: Notification) {
        hideEvaluationPanel()
    }
    
    @objc func shouldSelectCard(notifier: Notification) {
        selectCard(cardId: notifier.getCardIndex())
    }
    
    @objc func shouldDeselectCard(notifier: Notification) {
        deselectCard(cardId: notifier.getCardIndex())
    }
    
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
    
    @objc func shouldEvaluate(notifier: Notification) {
        fsm.acceptSetEvaluated(matchState: model.isMatchedSet)
        calculateScore()
        shouldDisplayEvaluationPanel = true
    }
    
    @objc func shouldClearSelection(notifier: Notification) {
        if notifier.getShouldDeselectAll() {
            // In case not a set, just deselect all
            deselectAllSelected()
        } else {
            // In case is a set, replace the selected cards
            replaceSelectedCardsByDealNew()
        }
    }
    
    // - MARK: Game Model actuators
    
    func newGamePressed() {
        model = SetGameViewModel.createModel()
        fsm = GameStateMachine(withFactory: SetGameViewModel.fsmFactory)
        fsm.start()
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
        if !shouldDisplayWinPanel {
            updateHintStructure()
        }
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
            assert(!isUpdatingMatches)
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
        updateHintStructure()
    }
    
    struct Constants {
        static let ScoreForTriple = 3
        static let ScoreForRun = 6
        
        static let StartScore = 100
        static let CostOfDealThree = 3
        static let CostOfHint = 6
    }
}
