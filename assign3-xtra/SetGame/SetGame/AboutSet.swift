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
    var message = """
 The code of this Swift version (c) 2022 by Sarah Smith is released under MIT License.  The image of Set (the Egyptian deity) is copyright Jeff Dahl, used here under CC-by-SA 4.0
license.  See the link above for details.
"""
    var infoType = InfoType.Information
    var handler: () -> Void
    
    var body: some View {
        VStack(spacing: 0.0) {
            headerLabel
            messageView
        }.clipShape(RoundedRectangle(cornerSize: Constants.CornerRadius))
            .shadow(radius: 10.0)
            .padding(.horizontal, 30.0)
            .onTapGesture {
                handler()
            }
    }
    
    private var picURL: URL {
        URL(string: "https://commons.wikimedia.org/w/index.php?curid=3306905")!
    }
    
    private var setURL: URL {
        URL(string: "https://en.wikipedia.org/wiki/Set_(card_game)")!
    }
    
    private var githubURL: URL {
        URL(string: "https://github.com/sarah-j-smith/cs193p-tuto/tree/main/assign3-xtra")!
    }
    
    private var stanfordURL: URL {
        URL(string: "https://cs193p.sites.stanford.edu/sites/g/files/sbiybj16636/files/media/file/assignment_3_0.pdf")!
    }
    
    private var messageView: some View {
        VStack(spacing: 0.0) {
            Image("Set").scaledToFit()
            
            Link("Set card game & rules - Wikipedia", destination: setURL)
            Text("The Set card game was designed by Marsha Falco in '74 & published by Set Enterprises in '91.").font(.caption).padding(EdgeInsets(top: 0.0, leading: 2.0, bottom: 3.0, trailing: 2.0))
            
            Link("Swift code MIT license Github - Sarah Smith", destination: githubURL)
            Text("The code of this Swift version (c) 2022 by Sarah Smith is released under MIT License.").font(.caption).padding(EdgeInsets(top: 0.0, leading: 2.0, bottom: 5.0, trailing: 2.0))
            
            Link("Assignment 3 - CS193p - Stanford Course", destination: stanfordURL)
            Text("This app is an academic exercise and released for free under the MIT license. See Stanford Developing Apps for iOS course").font(.caption).padding(EdgeInsets(top: 0.0, leading: 2.0, bottom: 5.0, trailing: 2.0))

            Link("Set illustration by Jeff Dahl - CC-by-SA 4.0", destination: picURL)
            Text("The image of Set (the Egyptian deity) is copyright Jeff Dahl, used here under CC-by-SA 4.0 license.").font(.caption).padding(EdgeInsets(top: 0.0, leading: 2.0, bottom: 3.0, trailing: 2.0))

//            Text(message)
//                .foregroundColor(.black)
//                .padding(10.0)
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

struct AboutSet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                AboutSet(
                    handler: { print ("Handler") })
            }
        }
    }
}
