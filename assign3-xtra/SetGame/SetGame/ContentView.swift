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
                }
                if game.shouldDisplayHintPanel {
                    hintPanel
                        .padding(30.0)
                        .zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                }
                if game.shouldDisplayEvaluationPanel {
                    setEvaluationPanel.transition(.offset(x: 0.0, y: geometry.size.height))
                        .padding(30.0)
                        .zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                }
                if game.shouldDisplayAboutPanel {
                    AboutSet(handler: {
                        withAnimation {
                            game.hideAboutPanel()
                        }
                    }).padding(4.0).zIndex(Constants.zDialogs)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
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
        return floor(Constants.CardPaddingBase / CGFloat(game.cards.count))
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
            }
            Spacer()
            settingsButton
                .labelStyle(VerticalLabelStyle())
        }
    }
    
    private var mainCardsView: some View {
        AspectVGrid(items: game.cards, aspectRatio: Constants.CardsAspect) { card in
            if (tabledCards.contains(card.id)) {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(cardPadding)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(Constants.zTableau + zOffsetForCard(card, inArray: game.cards))
                    .onTapGesture {
                        if game.isMatch {
                            let selectedIndexes = indexesOfSelectedCards
                            let threeCardsToReplace = game.selectedCards
                            withAnimation(.easeInOut(duration: 1.0)) {
                                for card in threeCardsToReplace {
                                    removeCardFromTableau(card)
                                }
                                game.cardTapped(card.id, isSelected: card.selected)
                            }
                            let newlyDealtCards = selectedIndexes.map {  game.cards[ $0 ] }
                            dealThreeAnimation(newlyDealtCards)
                        } else {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                game.cardTapped(card.id, isSelected: card.selected)
                            }
                        }
                    }
            } else {
                Color.clear
            }
        }
        .onAppear {
            for card in game.cards {
                withAnimation(dealAnimation(forCard: card)) {
                    placeCardInTableau(card)
                }
            }
        }
    }
    
    private func dealAnimation(forCard card: SetGameViewModel.Card) -> Animation {
        var delay = 0.0
        if let orderInDeck = game.cards.getIndexById(card.id) {
            delay = Double(orderInDeck) / Double(game.cards.count) * Constants.TotalDealDuration
        }
        return Animation.easeInOut(duration: Constants.DealDuration).delay(delay)
    }
    
    private func deal3Animation(forCard card: SetGameViewModel.Card, inArray cardsArray: Array<SetGameViewModel.Card>? = nil) -> Animation {
        var delay = 0.0
        let ary = cardsArray ?? Array( game.cards.suffix(3) )
        if let orderInDeck = ary.getIndexById(card.id) {
            delay = Double(orderInDeck) / Double(ary.count) * Constants.TotalDeal3Duration
        }
        return Animation.easeInOut(duration: Constants.Deal3Duration).delay(delay)
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
            Spacer()
            dealThreeMoreButton
                .labelStyle(VerticalLabelStyle())
                .disabled(game.deck.count < 3)
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
            handler: {
                withAnimation(.easeInOut(duration: 1.0)) {
                    game.hideHintPanel()
                }
            })
    }
    
    var setEvaluationPanel: some View {
        CardInfoView(
            cards: game.selectedCards,
            title: game.isMatch ? "It's a Match!" : "Not a Match!",
            message: game.matchResultExplanation,
            infoType: game.isMatch ? .Information : .Warning,
            handler: {
                withAnimation(.easeInOut(duration: 1.0)) {
                    game.hideEvaluationPanel()
                }
            })
    }
    
    private var settingsButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 1.0)) {
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
            withAnimation(.easeInOut(duration: 1.0)) {
                game.showHintPanel()
            }
        } label: {
            Label("Hint", systemImage: "questionmark.circle")
        }
    }
    
    private func removeSelectedCardsAnimation() {
        let threeCardsToReplace = game.selectedCards
        for card in threeCardsToReplace {
            withAnimation(.easeInOut(duration: 0.8)) {
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
                withAnimation(.easeInOut(duration: 0.8)) {
                    game.dealThreeMorePressed()
                }
                newlyDealtCards = selectedIndexes.map {  game.cards[ $0 ] }
            } else {
                withAnimation(.easeInOut(duration: 0.8)) {
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
    static var previews: some View {
        let gameVM = SetGameViewModel()
        
        ContentView(game: gameVM)
    }
}
