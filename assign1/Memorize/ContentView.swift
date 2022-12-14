//
//  ContentView.swift
//  Memorize
//
//  Created by Sarah Smith on 7/8/2022.
//

import SwiftUI

struct ContentView: View {
    
    let emojis: [ String: [String] ] = [
        "smileys": EmojiConstants.smileys,
        "animals": EmojiConstants.animals,
        "food": EmojiConstants.food,
        "stationery": EmojiConstants.stationery,
        "travel": EmojiConstants.travel
    ]
    
    @State var emojiCount = 25
    @State var theme = "animals"
    
    var body: some View {
        VStack {
            Spacer()
            Text("Memorize!").font(.largeTitle)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65, maximum: 100))]) {
                    ForEach(emojis[theme]![0..<emojiCount].shuffled(), id: \.self, content: { emoji in
                        CardView(content: emoji)
                            .aspectRatio(2/3, contentMode: .fit)
                    })
                }
            }
            .foregroundColor(.red).padding(.horizontal)
            HStack {
                smileysButton
                Spacer()
                animalsButton
                Spacer()
                foodButton
                Spacer()
                stationeryButton
                Spacer()
                travelButton
            }
            .labelStyle(VerticalLabelStyle())
            .padding([.horizontal, .bottom], 20)
        }
    }
    var smileysButton: some View {
        Button {
            theme = "smileys"
        } label: {
            Label("Smileys", systemImage:"face.smiling.fill")
        }.disabled(theme == "smileys")
    }
    var animalsButton: some View {
        Button {
            theme = "animals"
        } label: {
            Label("Animals", systemImage: "ladybug.fill")
        }.disabled(theme == "animals")
    }
    var foodButton: some View {
        Button {
            theme = "food"
        } label: {
            Label("Food", systemImage: "fork.knife")
        }.disabled(theme == "food")
    }
    var stationeryButton: some View {
        Button {
            theme = "stationery"
        } label: {
            Label("Books", systemImage: "books.vertical.circle.fill")
        }.disabled(theme == "stationery")
    }
    var travelButton: some View {
        Button {
            theme = "travel"
        } label: {
            Label("Travel", systemImage: "airplane.circle.fill")
        }.disabled(theme == "travel")
    }
}

struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.icon.font(.title2)
            configuration.title
        }
    }
}

struct CardView: View {
    var content: String
    @State var isFaceUp: Bool = true
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 20.0)
            if isFaceUp {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 3)
                Text(content)
                    .font(.largeTitle)
            } else {
                shape.fill()
            }
        }
        .onTapGesture {
            isFaceUp = !isFaceUp
        }
    }
}

/// Code to display the above UI in the preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        ContentView()
            .preferredColorScheme(.dark)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
