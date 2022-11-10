//
//  HintPanel.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 9/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import SwiftUI

struct HintPanel: View {
    
    var cards: [ SetGameViewModel.Card ]
    var title: String
    var message: String
    var infoType: InfoType
    var handler: () -> Void
    
    var body: some View {
        VStack(spacing: 0.0) {
            headerLabel
            cardsView
        }.clipShape(RoundedRectangle(cornerSize: Constants.CornerRadius))
            .shadow(radius: 10.0)
            .padding(.horizontal, 30.0)
            .onTapGesture {
                handler()
            }
    }
    
    private var cardsView: some View {
        VStack(spacing: 0.0) {
            Text(message)
                .foregroundColor(.black)
                .padding(EdgeInsets(
                    top: 10.0,
                    leading: 10.0,
                    bottom: cards.count > 0 ? 0.0 : 10.0,
                    trailing: 10.0))
            if cards.count > 0 {
                HStack {
                    ForEach(cards) { c in
                        CardView(card: c)
                            .aspectRatio(Constants.CardsAspect, contentMode: .fit)
                    }
                }.padding(10)
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.white)
        }
    }
    
    private var headerLabel: some View {
        ZStack {
            switch infoType {
            case .Warning:
                Label(self.title, systemImage: Constants.WarningSymbol)
                    .labelStyle(WarningDialogLabelStyle())
                    .padding(10.0)
            default:
                Label(self.title, systemImage: Constants.InfoSymbol)
                    .labelStyle(InfoDialogLabelStyle())
                    .padding(5.0)
            }
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.black).opacity(0.8)
        }
    }
    
    
    
    enum InfoType {
        case Warning
        case Information
    }
    
    struct Constants {
        static let WarningSymbol = "exclamationmark.triangle.fill"
        static let InfoSymbol = "checkmark.seal.fill"
        static let CardsAspect: CGFloat = 2/3
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
    
    struct WarningDialogLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 8) {
                configuration.icon.font(.title2).foregroundColor(.orange)
                configuration.title.font(.title2).foregroundColor(.white)
            }
        }
    }
}

struct HintPanel_Previews: PreviewProvider {
    static var previews: some View {
        let gameVM = SetGameModel()
        let cardsMatches = gameVM.matchesInPlayableCards
        let cards = gameVM.cardsFromMatchRecord(cardsMatches[0])
        
        let message = "There are \(cardsMatches.count) sets to find! Here's one to get you started."
        let noHintAvailable = "The current \(gameVM.playableCards.count) cards dealt do not have any Sets that can be made! Deal some more cards!"
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                HintPanel(
                    cards: [],
                    title: "No Sets",
                    message: noHintAvailable,
                    infoType: .Warning,
                    handler: { print ("Handler") })
                Spacer()
                HintPanel(
                    cards: cards,
                    title: "Hint",
                    message: message,
                    infoType: .Information,
                    handler: {
                        print("Handler")
                    })
            }
        }
    }
}
