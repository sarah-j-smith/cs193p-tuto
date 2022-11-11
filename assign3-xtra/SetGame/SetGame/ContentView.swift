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
        GeometryReader { geometry in
            ZStack {
                VStack {
                    gameHeader.padding(Constants.GameHeaderPadding)
                    mainCardsView.padding(.horizontal, cardPadding)
                    HStack {
                        newGameButton
                        Spacer()
                        hintButton
                        Spacer()
                        dealThreeMoreButton
                            .disabled(game.cards.count < 3)
                    }.padding()
                        .labelStyle(VerticalLabelStyle())
                }.zIndex(1.0)
                if game.shouldDisplayHintPanel {
                    dimmingBackground
                        .zIndex(2.0)
                    hintPanel
                        .padding(30.0)
                        .zIndex(3.0)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                }
                if game.shouldDisplayEvaluationPanel {
                    dimmingBackground
                        .zIndex(2.0)
                    setEvaluationPanel.transition(.offset(x: 0.0, y: geometry.size.height))
                        .padding(30.0)
                        .zIndex(3.0)
                        .transition(.offset(x: 0.0, y: geometry.size.height))
                }
            }
        }
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
    
    private var mainCardsView: some View {
        AspectVGrid(items: game.cards, aspectRatio: Constants.CardsAspect) { card in
            CardView(card: card).padding(cardPadding).onTapGesture {
                withAnimation(.easeInOut(duration: 3.0)) {
                    game.cardTapped(card.id, isSelected: card.selected)
                }
            }
        }
    }
    
    var hintPanel: some View {
        let hint = game.hintStructure
        return HintPanel(
            cards: hint.cards,
            title: "Hints",
            message: hint.message,
            infoType: hint.cards.count == 0 ? .Warning : .Information,
            handler: {
                withAnimation(.easeInOut(duration: 3.0)) {
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
                withAnimation(.easeInOut(duration: 3.0)) {
                    game.hideEvaluationPanel()
                }
            })
    }
    
    private var newGameButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 3.0)) {
                game.newGamePressed()
            }
        } label: {
            Label("New Game", systemImage: "shuffle.circle")
        }
    }
    
    private var hintButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 3.0)) {
                game.showHintPanel()
            }
        } label: {
            Label("Hint", systemImage: "questionmark.circle")
        }
    }
    
    private var dealThreeMoreButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 3.0)) {
                game.dealThreeMorePressed()
            }
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
