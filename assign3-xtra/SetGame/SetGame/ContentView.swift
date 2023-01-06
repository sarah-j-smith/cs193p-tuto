//
//  ContentView.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var game: SetGameViewModel
    
    // Indexes of cards that have been moved out of the deck but are not
    // placed into the tableau
    @State var tabledCards = Set<Int>()
    
    // namespace for the dealing matchGeometryEffect
    @Namespace private var dealingNamespace
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    gameHeader.padding(Constants.GameHeaderPadding)
                    mainCardsView.padding(.horizontal, cardPadding)
                    gameFooter.padding(.horizontal)
                }.zIndex(Constants.zTableau)
                VStack {
                    Spacer()
                    deckCardsView
                        .frame(width: (geometry.size.width / Constants.DeckWidthRatioGivenWidth),
                               height: (geometry.size.width / Constants.DeckWidthRatioGivenWidth) / Constants.CardsAspect)
                }
                if shouldDisplayDimmingPanel {
                    dimmingBackground
                        .zIndex(Constants.zDimmingPanel)
                        .accessibilityIdentifier("dimmingBackground")
                        .accessibilityHidden(true)
                }
                if game.shouldDisplayWinPanel {
                    winPanel
                        .padding(30.0)
                        .zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("Game_End_\(game.isWin ? "Win" : "Lose")")
                        .accessibilityLabel(game.isWin ? "Game Won" : "Game Lost")
                }
                if game.shouldDisplayHintPanel {
                    hintPanel
                        .padding(30.0)
                        .zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("Hint_Panel")
                        .accessibilityLabel(hintPanelAccessibilityLabel)
                }
                if game.shouldDisplayEvaluationPanel {
                    setEvaluationPanel.transition(.offset(x: 0.0, y: geometry.size.height))
                        .padding(10.0)
                        .zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                }
                if game.shouldDisplayAboutPanel {
                    AboutSet(handler: { shouldDisplayGuide in
                        withAnimation {
                            game.hideAboutPanel()
                            if shouldDisplayGuide {
                                game.showHowToPanel()
                            }
                        }
                    }).padding(4.0).zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("About_Panel")
                        .accessibilityLabel("About Cards of Set")
                }
                if game.shouldDisplayHowToPanel {
                    HowToPlay(handler: {
                        withAnimation {
                            game.hideHowToPanel()
                        }
                    }).padding(4.0).zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("HowTo_Panel")
                        .accessibilityLabel("How to Play Cards of Set")
                }
            }
        }
    }
    
    private var shouldDisplayDimmingPanel: Bool {
        return game.shouldDisplayAboutPanel || game.shouldDisplayHintPanel || game.shouldDisplayEvaluationPanel
    }
    
    private var dimmingBackground: some View {
        Rectangle()
            .fill(.black)
            .opacity(0.7)
            .ignoresSafeArea()
    }
    
    private var cardPadding: CGFloat {
        return floor(Constants.CardPaddingBase / CGFloat(max(game.cards.count, 12)))
    }
    
    private var gameHeader: some View {
        HStack {
            newGameButton
                .labelStyle(VerticalLabelStyle())
            Spacer()
            VStack {
                Text("SCORE")
                    .font(.callout)
                Text("\(game.score)")
                    .monospacedDigit()
                    .font(.title3)
                    .accessibilityIdentifier("Game_Score")
            }
            .accessibilityElement(children: .combine)
            Spacer()
            settingsButton
                .labelStyle(VerticalLabelStyle())
        }
    }
    
    private var totalDealDuration: Double {
        return game.testMode ? 0.01 : Constants.TotalDealDuration
    }
    
    private var dealDuration: Double {
        return game.testMode ? 0.01 : Constants.DealDuration
    }
    
    private var totalDeal3Duration: Double {
        return game.testMode ? 0.01 : Constants.TotalDeal3Duration
    }
    
    private var deal3Duration: Double {
        return game.testMode ? 0.01 : Constants.Deal3Duration
    }
    
    private var removeDuration: Double {
        return game.testMode ? 0.01 : Constants.RemoveDuration
    }
    
    private var panelDuration: Double {
        return game.testMode ? 0.01 : Constants.PanelDuration
    }
    
    private var mainCardsView: some View {
        return AspectVGrid(items: game.cards + game.dummys, aspectRatio: Constants.CardsAspect) { card in
            if (tabledCards.contains(card.id)) {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(cardPadding)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(Constants.zTableau + zOffsetForCard(card, inArray: game.cards))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(card.description)
                    .accessibilityIdentifier("Card_\(card.id)")
                    .onTapGesture {
                        if game.isMatch {
                            let selectedIndexes = indexesOfSelectedCards
                            let threeCardsToReplace = game.selectedCards
                            let hasReplacements = game.deck.count >= 3
                            withAnimation(.easeInOut(duration: removeDuration)) {
                                for card in threeCardsToReplace {
                                    removeCardFromTableau(card)
                                }
                                game.cardTapped(card.id, isSelected: card.selected)
                            }
                            if hasReplacements {
                                let newlyDealtCards = selectedIndexes.map {  game.cards[ $0 ] }
                                dealThreeAnimation(newlyDealtCards)
                            }
                        } else {
                            withAnimation(.easeInOut(duration: removeDuration)) {
                                game.cardTapped(card.id, isSelected: card.selected)
                            }
                        }
                    }
            } else {
                Color.clear
                    .padding(cardPadding)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Playable cards")
        .accessibilityIdentifier("Cards_Tableau")
        .onAppear {
            for card in game.cards {
                withAnimation(dealAnimation(forCard: card)) {
                    placeCardInTableau(card)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + afterTableauAnimation) {
                game.updateHintStructure()
            }
        }
    }
    
    private var afterTableauAnimation: CFTimeInterval {
        return totalDealDuration + dealDuration + 0.1
    }
    
    private func dealAnimation(forCard card: SetGameViewModel.Card) -> Animation {
        var delay = 0.0
        if let orderInDeck = game.cards.getIndexById(card.id) {
            delay = Double(orderInDeck) / Double(game.cards.count) * totalDealDuration
        }
        return Animation.easeInOut(duration: dealDuration).delay(delay)
    }
    
    private func deal3Animation(forCard card: SetGameViewModel.Card, inArray cardsArray: Array<SetGameViewModel.Card>? = nil) -> Animation {
        var delay = 0.0
        let ary = cardsArray ?? Array( game.cards.suffix(3) )
        assert(ary.count == 3)
        if let orderInDeck = ary.getIndexById(card.id) {
            delay = Double(orderInDeck) / 3.0 * totalDeal3Duration
        }
        return Animation.easeInOut(duration: deal3Duration).delay(delay)
    }
    
    private var decktop: [ SetGameViewModel.Card ] {
        return game.cards.filter { !tabledCards.contains($0.id) }
    }
    
    private var deckViewCards:  [ SetGameViewModel.Card ] {
        return decktop + game.deck
    }
    
    private var deckCardsView: some View {
        ZStack {
            ForEach(deckViewCards) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .offset(offsetForCard(card, inArray: deckViewCards))
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(Constants.zDeck + zOffsetForCard(card, inArray: deckViewCards))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(decktop.first?.description ?? "Empty deck")
        .accessibilityIdentifier("Deck_Card_\(decktop.first?.id ?? 0)")
    }
    
    private func offsetForCard(_ card: SetGameViewModel.Card, inArray ary: Array<SetGameViewModel.Card>) -> CGSize {
        if let orderInDeck = ary.getIndexById(card.id) {
            return CGSize(width: orderInDeck / 4, height: orderInDeck / 6)
        }
        return CGSize.zero
    }
    
    private func zOffsetForCard(_ card: SetGameViewModel.Card, inArray ary: Array<SetGameViewModel.Card>) -> Double {
        if let orderInDeck = ary.getIndexById(card.id) {
            return Double(ary.count - orderInDeck)
        }
        return 0.0
    }
    
    private func placeCardInTableau(_ card: SetGameViewModel.Card) {
        tabledCards.insert(card.id)
    }
    
    private func resetTableau(withCards cards: [ SetGameViewModel.Card ]) {
        tabledCards = Set( cards.map( \.id ) )
    }
    
    private func clearTableau() {
        tabledCards.removeAll()
    }
    
    private func removeCardFromTableau(_ card: SetGameViewModel.Card) {
        tabledCards.remove(card.id)
    }
    
    private var gameFooter: some View {
        HStack {
            hintButton
                .labelStyle(VerticalLabelStyle())
                .disabled(game.isUpdatingMatches)
            Spacer()
            dealThreeMoreButton
                .labelStyle(VerticalLabelStyle())
                .disabled(game.deck.count < 3 || game.isUpdatingMatches)
        }
    }
    
    var winPanel: some View {
        if game.isWin {
            return GameEndPanel(title: "You Won", message: "Nice work!", infoType: .Information) {
                game.hideWinPanel()
            }
        } else {
            return GameEndPanel(title: "You Lost", message: "Next time for sure!", infoType: .Warning) {
                game.hideWinPanel()
            }
        }
    }
    
    var hintPanel: some View {
        let hint = game.isMatch
            ? (cards: game.selectedCards, message: "You already have a match! Just tap any card.")
            : game.hintStructure
        return HintPanel(
            cards: hint.cards,
            title: "Hints",
            message: hint.message,
            infoType: hint.cards.count == 0 ? .Warning : .Information,
            handler: { howToRequested in
                withAnimation(.easeInOut(duration: panelDuration)) {
                    if howToRequested {
                        game.showHowToPanel()
                    }
                    game.hideHintPanel()
                }
            })
    }
    
    var hintPanelAccessibilityLabel: String {
        return game.isMatch
            ? "You already have a match! Just tap any card."
            : game.hintStructure.message
    }
    
    var setEvaluationPanel: some View {
        CardInfoView(
            cards: game.selectedCards,
            title: game.isMatch ? "It's a Match!" : "Not a Match!",
            message: game.matchResultExplanation,
            infoType: game.isMatch ? .Information : .Warning,
            handler: { doGuide in
                withAnimation(.easeInOut(duration: panelDuration)) {
                    if doGuide {
                        game.showHowToPanel()
                    }
                    game.hideEvaluationPanel()
                }
            })
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("Evaluation_Panel")
        .accessibilityLabel(game.isMatch ? "It's a Match!" : "Not a Match!")
    }
    
    private var settingsButton: some View {
        Button {
            withAnimation(.easeInOut(duration: panelDuration)) {
                game.showAboutPressed()
            }
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
    
    private var newGameButton: some View {
        Button {
            clearTableau()
            game.newGamePressed()
            for card in game.cards {
                withAnimation(dealAnimation(forCard: card)) {
                    placeCardInTableau(card)
                }
            }
        } label: {
            Label("New Game", systemImage: "shuffle.circle")
        }
    }
    
    private var hintButton: some View {
        Button {
            withAnimation(.easeInOut(duration: panelDuration)) {
                game.showHintPanel()
            }
        } label: {
            Label("Hint", systemImage: "questionmark.circle")
        }
    }
    
    private func removeSelectedCardsAnimation() {
        let threeCardsToReplace = game.selectedCards
        for card in threeCardsToReplace {
            withAnimation(.easeInOut(duration: removeDuration * 0.8)) {
                removeCardFromTableau(card)
            }
        }
    }

    private func dealThreeAnimation(_ newlyDealtCards: Array<SetGameViewModel.Card>) {
        for card in newlyDealtCards {
            withAnimation(deal3Animation(forCard: card, inArray: newlyDealtCards)) {
                placeCardInTableau(card)
            }
        }
    }
    
    private var indexesOfSelectedCards: Array<Int> {
        let cardIdsSelected = game.selectedCards.map( \.id )
        let cardIndexes = cardIdsSelected.map { idx in
            return game.cards.getIndexById(idx)!
        }
        return cardIndexes
    }
    
    private var dealThreeMoreButton: some View {
        Button {
            var newlyDealtCards: Array<SetGameViewModel.Card> = []
            if game.isMatch {
                let selectedIndexes = indexesOfSelectedCards
                removeSelectedCardsAnimation()
                withAnimation(.easeInOut(duration: deal3Duration)) {
                    game.dealThreeMorePressed()
                }
                newlyDealtCards = selectedIndexes.map {  game.cards[ $0 ] }
            } else {
                withAnimation(.easeInOut(duration: deal3Duration)) {
                    game.dealThreeMorePressed()
                }
                newlyDealtCards = Array( game.cards.suffix(3) )
            }
            dealThreeAnimation(newlyDealtCards)
        } label: {
            Label("Deal 3", systemImage: "square.3.stack.3d")
        }
    }
    
    struct Constants {
        static let CardsAspect: CGFloat = 2/3
        static let EvalPanelRadius: CGSize = CGSize(width: 20, height: 20)
        static let EvalPanelOpacity: CGFloat = 0.7
        static let GameHeaderPadding: CGFloat = 5
        static let CardPaddingBase: CGFloat = 60
        
        static let DeckWidthRatioGivenWidth: CGFloat = 6.0
        
        static let TotalDealDuration: Double = 5.0
        static let DealDuration: Double = 1.0
        
        static let TotalDeal3Duration: Double = 1.2
        static let Deal3Duration: Double = 0.8
        
        static let RemoveDuration: Double = 1.0
        static let PanelDuration: Double = 1.0
        
        static let zTableau: Double = 100.0
        static let zDeck: Double = 0.0
        static let zDimmingPanel: Double = 200.0
        static let zDialogs: Double = 220.0
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.icon.font(.largeTitle)
            configuration.title
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let fsmFactory = FSMFactory()
    static var previews: some View {
        let gameVM = SetGameViewModel(model: SetGameModel(), fsm: GameStateMachine(withFactory: fsmFactory))
        
        ContentView(game: gameVM)
    }
}
