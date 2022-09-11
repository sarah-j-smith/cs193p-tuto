//
//  ContentView.swift
//  Memorize
//
//  Created by Sarah Smith on 7/8/2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: EmojiMemoryGame
    
    var body: some View {
        VStack {
            gameHeader.padding(10.0)
            ZStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 65, maximum: 100))]) {
                        ForEach(viewModel.cards, content: { card in
                            CardView(card: card, themeColor: viewModel.currentThemeColor)
                                .aspectRatio(2/3, contentMode: .fit)
                                .onTapGesture {
                                    viewModel.choose(card)
                                }
                        })
                    }
                }
                .padding(.horizontal)
            }
            newGameButton
                .padding()
                .labelStyle(VerticalLabelStyle())
        }
    }
    var newGameButton: some View {
        Button {
            viewModel.newGame()
        } label: {
            Label("New Game", systemImage: "shuffle.circle")
        }
    }
    var gameHeader: some View {
        HStack {
            let themeTitle = Text("Theme: \(viewModel.currentTheme.name.capitalized)")
            if let gameScore = viewModel.currentScore {
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
    let card: MemoryGame<String>.Card
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
        ContentView(viewModel: game)
            .preferredColorScheme(.light)
        
        ContentView(viewModel: game)
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
