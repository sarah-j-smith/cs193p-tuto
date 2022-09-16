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
        VStack {
            gameHeader.padding(10.0)
            let cardsDealt = Array( game.cards[0 ..< 12] )
            AspectVGrid(items: cardsDealt, aspectRatio: 2/3) { card in
                CardView(card: card).padding(4.0)
            }.padding(.horizontal)
            HStack {
                newGameButton
                Spacer()
                dealThreeMoreButton
            }.padding()
                .labelStyle(VerticalLabelStyle())
        }
    }
    
    private var newGameButton: some View {
        Button {
            print("New game pressed")
        } label: {
            Label("New Game", systemImage: "shuffle.circle")
        }
    }
    
    private var dealThreeMoreButton: some View {
        Button {
            print("Deal three more pressed")
        } label: {
            Label("Deal 3", systemImage: "square.3.stack.3d")
        }
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
        ContentView(game: gameVM)
    }
}
