//
//  GameEndPanel.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 5/12/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import SwiftUI

struct GameEndPanel: View {

    var title: String
    var message: String
    var infoType: InfoType
    var handler: () -> Void
    
    var body: some View {
        VStack(spacing: 0.0) {
            headerLabel
            gameEndView
            dismissButton
                .zIndex(-1.0)
        }.clipShape(RoundedRectangle(cornerSize: Constants.CornerRadius))
            .shadow(radius: 10.0)
            .padding(.horizontal, 30.0)
    }
    
    private var gameEndView: some View {
        VStack(spacing: 0.0) {
            Text(message)
                .foregroundColor(.black)
                .padding(20.0)
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
                .fill(.white)
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

struct GameEndPanel_Previews: PreviewProvider {
    static var previews: some View {
        let message = "Great job! You won this time!"
        let noHintAvailable = "Oh no! You did not win this time!"
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                GameEndPanel(
                    title: "Loss",
                    message: noHintAvailable,
                    infoType: .Warning,
                    handler: { print ("Handler") })
                Spacer()
                GameEndPanel(
                    title: "Win",
                    message: message,
                    infoType: .Information,
                    handler: {
                        print("Handler")
                    })
            }
        }
    }
}
