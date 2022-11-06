//
//  ContentView.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var game: SetGameViewModel
    
    var body: some View {
        ZStack {
            VStack {
                gameHeader.padding(Constants.GameHeaderPadding)
                mainCardsView.padding(.horizontal, cardPadding)
                HStack {
                    newGameButton
                    if game.shouldDisplayEvaluationPanel {
                        setEvaluationPanel
                            .padding(.horizontal)
                    } else {
                        Spacer()
                    }
                    dealThreeMoreButton
                        .disabled(game.cards.count < 3)
                }.padding()
                    .labelStyle(VerticalLabelStyle())
            }
        }
    }
    
    private var cardPadding: CGFloat {
        return floor(Constants.CardPaddingBase / CGFloat(game.cards.count))
    }
    
    private var mainCardsView: some View {
        AspectVGrid(items: game.cards, aspectRatio: Constants.CardsAspect) { card in
            CardView(card: card).padding(cardPadding).onTapGesture {
                game.cardTapped(card.id, isSelected: card.selected)
            }
        }
    }
    
    var setEvaluationPanel: some View {
        VStack {
            Text(game.isMatch ? "✅ It's a Match!" : "❌ Not a Match!")
                .font(.title2)
            Text("Dealt: \(game.cards.count) - Deck: \(game.deck.count)")
        }
    }
    
    private var newGameButton: some View {
        Button {
            game.newGamePressed()
        } label: {
            Label("New Game", systemImage: "shuffle.circle")
        }
    }
    
    private var dealThreeMoreButton: some View {
        Button {
            game.dealThreeMorePressed()
        } label: {
            Label("Deal 3", systemImage: "square.3.stack.3d")
        }
    }
    
    private var gameHeader: some View {
        HStack {
            Text("Set Game")
        }
    }
    
    struct Constants {
        static let CardsAspect: CGFloat = 2/3
        static let EvalPanelRadius: CGSize = CGSize(width: 20, height: 20)
        static let EvalPanelOpacity: CGFloat = 0.7
        static let GameHeaderPadding: CGFloat = 10
        static let CardPaddingBase: CGFloat = 60
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
