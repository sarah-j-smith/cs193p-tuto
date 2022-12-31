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
license.  Tap the link below for details.
"""

    let courseInfo = """
This SwiftUI implementation of Set is an academic exercise. Tap the Stanford Developing Apps
for iOS course link below for more information.
"""

    let codeInfo = """
The code of this Swift version (c) 2022 by Sarah Smith is released under MIT License.
"""

    let cardGame = """
To buy the original card game of Set, visit Set Enterprises, now owned by PlayMonster.
See the link below. This app is not affiliated with Set Enterprises or PlayMonster.
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
            Image("Set")
                .scaledToFit()
            
            aboutPanel(linkText: "Egyptian Deity \"Set\"", linkURL: picURL, detailText: picAttribution)
            
            aboutPanel(linkText: "Set Game (Wikipedia)", linkURL: setURL, detailText: attribution)
            
            aboutPanel(linkText: "Stanford Course CS193p", linkURL: stanfordURL, detailText: courseInfo)
            
            aboutPanel(linkText: "MIT Licensed Code on Github", linkURL: githubURL, detailText: codeInfo)
            
            aboutPanel(linkText: "Set Enterprises", linkURL: playMonsterURL, detailText: cardGame)
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.white)
        }
    }
    
    private func aboutPanel(linkText: String, linkURL: URL, detailText: String) -> some View {
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

struct AboutSet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                AboutSet(
                    handler: { print ("Handler") })
                Spacer()
            }
        }
    }
}
