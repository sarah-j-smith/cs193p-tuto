//
//  CardInfoDialog.swift
//  SetGame
//
//  Created by Sarah Smith on 24/9/2022.
//

import SwiftUI

struct CardInfoView: View {
    
    var cards: [ SetGameViewModel.Card ]
    var title: String
    var message: String
    var infoType: InfoType
    
    var denominations: Set<Int> {
        Set<Int>( cards.map(\.numberOfShapes) )
    }
    
    var shapes: Set<SetGameModel.ShapeFeature> {
        Set<SetGameModel.ShapeFeature>( cards.map(\.shape) )
    }
    
    var colors: Set<SetGameModel.ColorFeature> {
        Set<SetGameModel.ColorFeature>( cards.map(\.color) )
    }
    
    var shadings: Set<SetGameModel.ShadingFeature> {
        Set<SetGameModel.ShadingFeature>( cards.map(\.shading) )
    }
    
    
    var denominationsSetKind: SetKind {
        denominations.count == 1 ? .Match : .Run
    }
    
    var shapesSetKind: SetKind {
        shapes.count == 1 ? .Match : .Run
    }
    
    var colorsSetKind: SetKind {
        colors.count == 1 ? .Match : .Run
    }
    
    var shadingsSetKind: SetKind {
        shadings.count == 1 ? .Match : .Run
    }
    
    var handler: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 0.0) {
            headerLabel
            cardsView
            HStack {
                howToButton
                Spacer()
                dismissButton
            }
            .frame(maxWidth: .infinity)
            .zIndex(10.0)
            .background {
                Rectangle()
                    .fill(.white)
                    .shadow(radius: 2.0)
            }
        }.clipShape(RoundedRectangle(cornerSize: Constants.CornerRadius))
            .shadow(radius: 10.0)
            .padding(.horizontal, 30.0)
    }
    
    var matchPanelColor: some View {
        HStack {
            Label("COLOR", systemImage: "paintpalette")
                .padding(Constants.PointCardInsets)
            Spacer()
            if colorsSetKind == .Run {
                ForEach(cards) { c in
                    Image(systemName: "rectangle.inset.filled")
                        .foregroundColor(c.color.uiColor)
                }
            } else {
                Image(systemName: "rectangle.inset.filled")
                    .foregroundColor(cards[0].color.uiColor)
                Text("X 3")
            }
            Spacer()
            Label(colorsSetKind.textLabel(), systemImage: colorsSetKind.imageName())
            Spacer()
            Label("POINTS", systemImage: colorsSetKind == .Run ? "6.circle" : "3.circle")
            .padding(Constants.PointCardInsets)
            .background { Rectangle().fill(.white).shadow(radius: 2.0) }
        }
        .labelStyle(SmallIconStyle())
        .padding(5)
        .frame(maxWidth: .infinity)
    }
    
    var matchPanelFill: some View {
        HStack {
            Label("FILL", systemImage: "paintbrush.pointed")
                .padding(Constants.PointCardInsets)
            Spacer()
            if shadingsSetKind == .Run {
                ForEach(cards) { c in
                    Image(systemName: c.shading.sfSymbolName())
                }
            } else {
                Image(systemName: cards[0].shading.sfSymbolName())
                Text("X 3")
            }
            Spacer()
            Label(shadingsSetKind.textLabel(), systemImage: shadingsSetKind.imageName())
            Spacer()
            Label("POINTS", systemImage: shadingsSetKind == .Run ? "6.circle" : "3.circle")
            .padding(Constants.PointCardInsets)
            .background { Rectangle().fill(.white).shadow(radius: 2.0) }
        }
        .labelStyle(SmallIconStyle())
        .padding(5)
    }
    
    var matchPanelCount: some View {
        HStack {
            Label("COUNT", systemImage: "123.rectangle")
                .padding(Constants.PointCardInsets)
            Spacer()
            if denominationsSetKind == .Run {
                ForEach(cards) { c in
                    Image(systemName: "\(c.numberOfShapes).square")
                }
            } else {
                Image(systemName: "\(cards[0].numberOfShapes).square")
                Text("X 3")
            }
            Spacer()
            Label(denominationsSetKind.textLabel(), systemImage: denominationsSetKind.imageName())
            Spacer()
            Label("POINTS", systemImage: denominationsSetKind == .Run ? "6.circle" : "3.circle")
            .padding(Constants.PointCardInsets)
            .background { Rectangle().fill(.white).shadow(radius: 2.0) }
        }
        .labelStyle(SmallIconStyle())
        .padding(5)
        .frame(maxWidth: .infinity)
    }
    
    var matchPanelShape: some View {
        HStack {
            Label("SHAPE", systemImage: "square.on.circle")
                .padding(Constants.PointCardInsets)
            Spacer()
            if shapesSetKind == .Run {
                ForEach(cards) { c in
                    Image(systemName: c.shape.sfSymbolName())
                }
            } else {
                Image(systemName: cards[0].shape.sfSymbolName())
                Text("X 3")
            }
            Spacer()
            Label(shapesSetKind.textLabel(), systemImage: shapesSetKind.imageName())
            Spacer()
            Label("POINTS", systemImage: shapesSetKind == .Run ? "6.circle" : "3.circle")
            .padding(Constants.PointCardInsets)
            .background { Rectangle().fill(.white).shadow(radius: 2.0) }
        }
        .labelStyle(SmallIconStyle())
        .padding(5)
        .frame(maxWidth: .infinity)
    }
    
    enum SetKind {
        case Match
        case Run
        
        func textLabel() -> String {
            switch self {
            case .Match:
                return "MATCH"
            case .Run:
                return "RUN"
            }
        }
        
        func imageName() -> String {
            switch self {
            case .Match:
                return "square.3.layers.3d"
            case .Run:
                return "square.stack.3d.forward.dottedline.fill"
            }
        }
    }
    
    
    private var howToButton: some View {
        ZStack {
            Button {
                handler(true)
            } label: {
                Label("Guide", systemImage: "book.circle").labelStyle(VerticalLabelStyle())
            }
            .padding(EdgeInsets(top: 15.0, leading: 30.0, bottom: 15.0, trailing: 30.0))
            .accessibilityIdentifier("Dismiss_HowTo")
            .accessibilityLabel("Dismiss and Launch How-to")
        }
    }
    
    private var dismissButton: some View {
        ZStack {
            Button {
                handler(false)
            } label: {
                Label("Got it", systemImage: "hand.thumbsup.circle").labelStyle(VerticalLabelStyle())
            }
            .padding(EdgeInsets(top: 15.0, leading: 30.0, bottom: 15.0, trailing: 30.0))
            .accessibilityIdentifier("Dismiss_OK")
            .accessibilityLabel("Dismiss")
        }
    }
    
    private var cardsView: some View {
        VStack(spacing: 0.0) {
            Text(message)
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 10.0, leading: 10.0, bottom: 0.0, trailing: 10.0))
            HStack {
                ForEach(cards) { c in
                    CardView(card: c)
                        .aspectRatio(Constants.CardsAspect, contentMode: .fit)
                }
            }.padding(10)
            if (infoType == .Information) {
                matchPanelColor
                    .background { Rectangle().fill(Constants.ScorePanelDark) }
                matchPanelCount
                    .background { Rectangle().fill(Constants.ScorePanelLight) }
                matchPanelShape
                    .background { Rectangle().fill(Constants.ScorePanelDark) }
                matchPanelFill
                    .background { Rectangle().fill(Constants.ScorePanelLight) }
            }
        }
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
        static let PointCardInsets = EdgeInsets(top: 2.0, leading: 10.0, bottom: 2.0, trailing: 10.0)
        
        static let ScorePanelLight = Color("ScorePanelLight")
        static let ScorePanelDark = Color("ScorePanelDark")
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
    
    
    struct SmallIconStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .center, spacing: 3) {
                configuration.icon.font(.title)
                configuration.title.font(.caption)
            }
        }
    }
}

extension SetGameModel.ShapeFeature {
    func sfSymbolName() -> String {
        switch self {
        case .Diamond:
            return "diamond"
        case .Oval:
            return "capsule"
        case .Squiggle:
            return "alternatingcurrent"
        }
    }
}

extension SetGameModel.ShadingFeature {
    func sfSymbolName() -> String {
        switch self {
        case .OpenShading:
            return "rectangle"
        case .SolidShading:
            return "rectangle.inset.fill"
        case .StripedShading:
            return "circle.filled.pattern.diagonalline.rectangle"
        }
    }
}

struct CardInfoView_Previews: PreviewProvider {
    
    static func prevModel() -> SetGameModel {
        var model = SetGameModel()
        let cards = model.matchesInPlayableCards
        if let match = cards.first {
            model.toggleCardSelection(model.cards[ match.0 ].id)
            model.toggleCardSelection(model.cards[ match.1 ].id)
            model.toggleCardSelection(model.cards[ match.2 ].id)
        } else {
            model.toggleCardSelection(model.cards[ 4 ].id)
            model.toggleCardSelection(model.cards[ 5 ].id)
            model.toggleCardSelection(model.cards[ 8 ].id)
        }
        return model
    }
    
    static let fsmFactory = FSMFactory()
    static var previews: some View {
        let model = prevModel()
        ZStack {
            Rectangle().fill(.white).ignoresSafeArea()
            VStack {
                CardInfoView(
                    cards: model.selectedCards,
                    title: model.isMatchedSet ? "Yes! It's a Match!" : "Not a Match!",
                    message: model.matchResultExplanation,
                    infoType: model.isMatchedSet ? .Information : .Warning,
                    handler: { doGuide in
                        print("Handler \(doGuide)")
                    })
            }
            .padding(10.0)
        }
    }
}
