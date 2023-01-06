//
//  AboutSet.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 11/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import SwiftUI

struct AboutSet: View {
    
    var title = "About Cards of Set"
    
    let attribution = """
The Set card game was designed by Marsha Falco in 1974 and published by Set
Enterprises in 1991.
"""
    
    let picAttribution = """
The image of Set (the Egyptian deity) is copyright Jeff Dahl, used here under CC-by-SA 4.0
license.
"""

    let courseInfo = """
This SwiftUI implementation of Set is an academic exercise.
"""

    let codeInfo = """
The code of this Swift version (c) 2022 by Sarah Smith is released under MIT License.
"""

    let cardGame = """
To buy the original card game of Set, visit Set Enterprises, now owned by PlayMonster.  This app is not affiliated with Set Enterprises or PlayMonster.
"""
    
    let guideText = """
Looking for instructions?  Tap "Guide" below to see How to Play.  Or keep scrolling for attributions and more about this app.
"""
    
    var handler: (Bool) -> Void
    
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
    
    private var picURL: URL {
        URL(string: "https://commons.wikimedia.org/w/index.php?curid=3306905")!
    }
    
    private var setURL: URL {
        URL(string: "https://en.wikipedia.org/wiki/Set_(card_game)")!
    }
    
    private var playMonsterURL: URL {
        URL(string: "https://www.playmonster.com/product/set/")!
    }
    
    private var githubURL: URL {
        URL(string: "https://github.com/sarah-j-smith/cs193p-tuto/tree/main/assign3-xtra")!
    }
    
    private var stanfordURL: URL {
        URL(string: "https://cs193p.sites.stanford.edu/sites/g/files/sbiybj16636/files/media/file/assignment_3_0.pdf")!
    }
    
    private var messageView: some View {
        VStack {
            
            goToGuideButton(detailText: guideText)
            
            Image("Set")
                .scaledToFit()
                .padding(10.0)
            
            aboutPanelWithLink("Egyptian Deity \"Set\"", linkURL: picURL, detailText: picAttribution)
            
            aboutPanelWithLink("Set Game (Wikipedia)", linkURL: setURL, detailText: attribution)
            
            aboutPanelWithLink("Stanford Course CS193p", linkURL: stanfordURL, detailText: courseInfo)
            
            aboutPanelWithLink("MIT Licensed Code on Github", linkURL: githubURL, detailText: codeInfo)
            
            aboutPanelWithLink("Set Enterprises", linkURL: playMonsterURL, detailText: cardGame)
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
                .lineLimit(5)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
            Link(linkText, destination: linkURL)
                .padding(30)
        }
        .background { Rectangle().fill(.white).shadow(radius: 2.0) }
    }
    
    private func goToGuideButton(detailText: String) -> some View {
        return VStack {
            Text(detailText)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(15.0)
                .background {
                    Rectangle().fill(.white)
                }
            Button {
                handler(true)
            } label: {
                Text("Guide")
            }.padding(20)
        }
        .background {
            Rectangle().fill(.white).shadow(radius: 2.0)
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
                handler(false)
            } label: {
                Text("OK")
            }
            .padding(EdgeInsets(top: 20.0, leading: 30.0, bottom: 20.0, trailing: 30.0))
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

struct AboutSet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                AboutSet(
                    handler: { shouldDisplayHowTo in
                        print ("Handler")
                    })
                Spacer()
            }
        }
    }
}
