//
//  ContentView.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var game: SetGameViewModel
    
    @ObservedObject var gameState: GamePlayState
    
    var body: some View {
        ZStack {
            VStack {
                gameHeader.padding(10.0)
                let cardsDealt = Array( game.cards )
                let cardPadding = floor(CGFloat(60) / CGFloat(cardsDealt.count))
                AspectVGrid(items: cardsDealt, aspectRatio: 2/3) { card in
                    CardView(card: card).padding(cardPadding).onTapGesture {
                        if (card.selected) {
                            if gameState.deselectionEnabled {
                                game.cardTapped(cardId: card.id)
                                gameState.deselectCard()
                            }
                        } else {
                            if (gameState.selectionEnabled) {
                                game.cardTapped(cardId: card.id)
                                gameState.selectCard()
                            }
                            if (gameState.flag == .ThreeCardsSelected) {
                                gameState.evaluate(isMatch: game.isMatch)
                            }
                        }
                    }
                }.padding(.horizontal, cardPadding)
                HStack {
                    newGameButton
                    Spacer()
                    dealThreeMoreButton
                }.padding()
                    .labelStyle(VerticalLabelStyle())
            }
            if gameState.shouldDisplayEvaluationPanel {
                VStack(alignment: .trailing) {
                    HStack {
                        ForEach(game.selectedCards) { c in
                            CardView(card: c)
                        }
                    }
                    switch gameState.flag {
                    case .IsMatchSelection:
                        Text("Yes! It's a Match!")
                    default:
                        Text("Not a Match!")
                    }
                }.padding()
                    .font(.largeTitle)
                    .background {
                        RoundedRectangle(cornerSize: CGSize(width: 20.0, height: 20.0))
                            .fill(.black)
                            .opacity(0.7)
                    }
            }
        }
    }
    
    private var newGameButton: some View {
        Button {
            gameState.beginGame()
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
        }.disabled(game.cards.count >= SetGameModel.UniqueCardCount)
    }
    
    private var gameHeader: some View {
        HStack {
            Text("Set Game")
        }
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
        let gamePlayState = GamePlayState()

        ContentView(game: gameVM, gameState: gamePlayState)
    }
}
