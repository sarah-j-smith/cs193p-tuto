//
//  AboutSet.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 11/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import SwiftUI

struct HowToPlay: View {
    
    var title = "Spot Sets to Win!"
    
    let rules = """
     How to spot a set? Cards have:
    
    ◦ SHAPES - diamond, pill & wavy-line
    ◦ COLORS - orange, cyan & purple
    ◦ COUNT of shapes - 1, 2 or 3
    ◦ FILL - solid, striped or open
    
    A SET is 3 cards where each of shapes, colors, count & fill is all the same (MATCH), OR all different (RUN).
    """
    
    let rulesDetail = """
    Here is a MATCH for SHAPE (all pills), COUNT (all 1's) and FILL (all solid); and there's a RUN for COLORS: orange, cyan and purple. That's a SET!
    
    You score when you tap (3) cards to make a SET: 3 points for a MATCH, and 6 points for a RUN. Above is worth 15 points.
    
    So that you can use hints and deal 3's straightaway you get 100 points at game start.
    """
    
    let gamePlay = """
    If you hit the hint button it costs you 6 points, and hitting the deal 3 button costs 3 points. Sometimes a deal has no matches: in that case deal 3 is free. A hint that there are no matches is also free.
    
    The Set deck has exactly 1 copy of each possible card: this means you can never have a Set of 3 cards where there are all 4 MATCH - there has to be at least one RUN.
    
    Tapping a Set scores points, then on making a new selection the Set is cleared, and filled with new cards from the deck.
    
    When the deck of 81 cards is exhausted, cards cannot be dealt any more; and then once all dealt cards are used up the game ends.
    """

    var handler: () -> Void
    
    var body: some View {
        VStack(spacing: 0.0) {
            headerLabel
            ScrollView {
                messageView
            }
            dismissButton
        }.clipShape(RoundedRectangle(cornerSize: Constants.CornerRadius))
            .shadow(radius: 10.0)
            .padding(.horizontal, 30.0)
    }

    private var messageView: some View {
        VStack {
            aboutPanel(detailText: rules)
            
            Image("its-a-set")
                .scaledToFit()
            
            aboutPanel(detailText: rulesDetail)
            
            Image("full-game-screenshot")
            
            aboutPanel(detailText: gamePlay)
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.white)
        }
    }
    
    private func aboutPanelWithLink(_ linkText: String, linkURL: URL, detailText: String) -> some View {
        return VStack {
            Text(detailText.replacingOccurrences(of: "\n", with: " "))
                .frame(maxWidth: .infinity)
                .padding(5.0)
                .background {
                    Rectangle().fill().foregroundColor(.yellow.opacity(0.4))
                }
            Link(linkText, destination: linkURL)
                .padding()
        }
        .background {
            Rectangle().fill().foregroundColor(.white).shadow(radius: 2.0)
        }
    }
    
    private func aboutPanel(detailText: String) -> some View {
        return VStack {
            Text(detailText)
                .frame(maxWidth: .infinity)
                .padding(5.0)
                .background {
                    Rectangle().fill().foregroundColor(.white)
                }
        }
        .background {
            Rectangle().fill().foregroundColor(.white).shadow(radius: 2.0)
        }
    }
    
    private var headerLabel: some View {
        ZStack {
            Label(self.title, systemImage: Constants.InfoSymbol)
                .labelStyle(InfoDialogLabelStyle())
                .padding(5.0)
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.black).opacity(0.8)
        }
    }
    
    private var dismissButton: some View {
        ZStack {
            Button {
                handler()
            } label: {
                Text("OK")
            }
            .padding(EdgeInsets(top: 15.0, leading: 30.0, bottom: 15.0, trailing: 30.0))
            .accessibilityIdentifier("Dismiss_OK")
            .accessibilityLabel("Dismiss")
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.white).shadow(radius: 5.0)
        }
    }
    
    struct Constants {
        static let InfoSymbol = "info.circle"
        static let CornerRadius = CGSize(width: 10.0, height: 10.0)
    }
    
    struct InfoDialogLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 8) {
                configuration.icon.font(.title2).foregroundColor(.blue)
                configuration.title.font(.title2).foregroundColor(.white)
            }
        }
    }
}

struct HowToPlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                HowToPlay(
                    handler: { print ("Handler") })
                Spacer()
            }
        }
    }
}
