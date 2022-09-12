//
//  ContentView.swift
//  Memorize
//
//  Created by Sarah Smith on 7/8/2022.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        VStack {
            gameHeader.padding(10.0)
            AspectVGrid(items: game.cards, aspectRatio: 2/3, content: { card in
                CardView(card: card, themeColor: game.currentThemeColor)
                    .aspectRatio(2/3, contentMode: .fit)
                    .onTapGesture {
                        game.choose(card)
                    }.padding(5.0)
            }).padding(.horizontal)
            newGameButton
                .padding()
                .labelStyle(VerticalLabelStyle())
        }
    }
    private var newGameButton: some View {
        Button {
            game.newGame()
        } label: {
            Label("New Game", systemImage: "shuffle.circle")
        }
    }
    private var gameHeader: some View {
        HStack {
            let themeTitle = Text("Theme: \(game.currentTheme.name.capitalized)")
            if let gameScore = game.currentScore {
                themeTitle.font(.title2)
                Spacer()
                Text("Score: \(gameScore)")
            } else {
                themeTitle.font(.title)
            }
        }
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.title
            configuration.icon.font(.largeTitle)
        }
    }
}

struct CardView: View {
    let card: EmojiMemoryGame.Card
    let themeColor: Color
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let shape = RoundedRectangle(cornerRadius: 10.0)
                if card.isFaceUp {
                    shape.fill().foregroundColor(.white)
                    shape.strokeBorder(lineWidth: Constants.borderThickness)
                    Text(card.content)
                        .font(.system(size: .minimum(geometry.size.width, geometry.size.height) * 0.9))
                } else if card.isMatched {
                    shape.opacity(0.0)
                } else {
                    shape.fill(.linearGradient(Gradient(colors: [themeColor.opacity(0.2), themeColor]), startPoint: UnitPoint(x: 0.2, y: 0.1), endPoint: UnitPoint(x: 0.8, y: 0.9)))
                    shape.strokeBorder(lineWidth: Constants.borderThickness)
                }
            }.foregroundColor(themeColor)
        }
    }
    
    struct Constants {
        static let cornerRadius: CGFloat = 10.0
        static let borderThickness: CGFloat = 3.0
    }
}

/// Code to display the above UI in the preview

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let game = EmojiMemoryGame()
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
        
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
