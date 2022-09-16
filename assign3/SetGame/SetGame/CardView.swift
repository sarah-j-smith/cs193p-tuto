//
//  CardView.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import SwiftUI

struct CardView: View {
    let card: SetGameViewModel.Card
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: Constants.cornerRadius)
            shape.fill().foregroundColor(.white)
            shape.strokeBorder(lineWidth: Constants.borderThickness).opacity(0.6)
            let vPad = card.shape == .Oval ? 8.0 : 0.0
            VStack {
                ForEach(0 ..< 3) { ix in
                    if (card.numberOfShapes > ix) {
                        let symbol = CardSymbolPainter(shapeType: card.shape)
                        switch card.shading {
                        case .SolidShading:
                            ZStack {
                                symbol
                                    .stroke(lineWidth: Constants.borderThickness)
                                    .fill(card.color.uiColor)
                                    .aspectRatio(2.0, contentMode: .fit)
                                symbol
                                    .fill(card.color.uiColor)
                                    .opacity(0.6)
                                    .aspectRatio(2.0, contentMode: .fit)
                            }
                        case .OpenShading:
                            ZStack {
                                symbol
                                    .fill(.white)
                                    .opacity(0.6)
                                    .aspectRatio(2.0, contentMode: .fit)
                                symbol
                                    .stroke(lineWidth: Constants.borderThickness * 1.2)
                                    .fill(card.color.uiColor)
                                    .aspectRatio(2.0, contentMode: .fit)
                            }
                        case .StripedShading:
                            ZStack {
                                symbol
                                    .fill(card.color.uiColor)
                                    .opacity(0.3)
                                    .aspectRatio(2.0, contentMode: .fit)
                                symbol
                                    .stroke(lineWidth: Constants.borderThickness)
                                    .fill(card.color.uiColor)
                                    .aspectRatio(2.0, contentMode: .fit)
                            }
                        }
                    }
                }.padding(
                    EdgeInsets(top: vPad, leading: 0.0, bottom: vPad, trailing: 0.0))
            }.padding(20.0)
        }
    }

    struct Constants {
        static let cornerRadius: CGFloat = 10.0
        static let borderThickness: CGFloat = 3.0
    }
}

struct CardSymbolPainter: Shape {
    
    let shapeType: SetGameModel.ShapeFeature
    private let baseShape = Capsule()
    
    func path(in rect: CGRect) -> Path {
        switch shapeType {
        case .Diamond:
            return diamondPath(in: rect)
        case .Squiggle:
            return wigglyLinePath(in: rect)
        case .Oval:
            return baseShape.path(in: rect)
        }
    }
    
    private func diamondPath(in rect: CGRect) -> Path {
        let threeOClock = CGPoint(x: rect.width, y: rect.midY)
        let twelveOClock = CGPoint(x: rect.midX, y: 0)
        let nineOClock = CGPoint(x: 0.0, y: rect.midY)
        let sixOClock = CGPoint(x: rect.midX, y: rect.height)
        var p = Path()
        p.move(to: threeOClock) // 3 o'clock
        p.addLine(to: twelveOClock)  // 12 o'clock
        p.addLine(to: nineOClock)  // 9 o'clock
        p.addLine(to: sixOClock) // // 6 o'clock
        p.addLine(to: threeOClock)
        return p
    }

    private func wigglyLinePath(in rect: CGRect) -> Path {
        // Wavy line is made up of 4 equal arcs - so divide width by 4
        let arcWidth = (rect.width/CGFloat(4.0))
        // Wavy line inflection is at 45 degrees
        let inflect = Angle(degrees: 45)
        let arcRadius = arcWidth / sin(inflect.radians)
        let insetHeight = arcRadius - arcWidth
        let inCurveYCenterOffset = insetHeight * 2 - arcRadius
        var p = Path()
        p.move(to: CGPoint(x: 0, y: insetHeight))
        p.addArc(center: CGPoint(x: arcWidth, y: arcRadius),
                 radius: arcRadius, startAngle: Angle(degrees: 225.0),
                 endAngle: Angle(degrees: 315.0), clockwise: false)
        p.addArc(center: CGPoint(x: arcWidth + rect.midX, y: inCurveYCenterOffset),
                 radius: arcRadius, startAngle: Angle(degrees: 135),
                 endAngle: Angle(degrees: 45), clockwise: true)
        p.addLine(to: CGPoint(x: rect.width, y: rect.height - CGFloat(2 * insetHeight)))
        p.addArc(center: CGPoint(x: arcWidth + rect.midX, y: rect.height - arcRadius),
                 radius: arcRadius, startAngle: Angle(degrees: 45),
                 endAngle: Angle(degrees: 135), clockwise: false)
        p.addArc(center: CGPoint(x: arcWidth, y: rect.height - inCurveYCenterOffset),
                 radius: arcRadius, startAngle: Angle(degrees: 315.0),
                 endAngle: Angle(degrees: 225.0), clockwise: true)
        p.addLine(to: CGPoint(x: 0, y: insetHeight))
        return p
    }
}

extension SetGameModel.ColorFeature {
    var uiColor: Color {
        switch self {
        case .Green:
            return Color.green
        case .Purple:
            return Color.purple
        case .Red:
            return Color.red
        }
    }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let gamePreviewModel = SetGameViewModel()
        Group {
            ZStack {
                Rectangle().fill(.gray).opacity(0.3).ignoresSafeArea()
                HStack {
                    VStack {
                        // 1 of Green Solid Squiggle
                        CardView(card: gamePreviewModel.cards[1])
                            .aspectRatio(2/3, contentMode: .fit)
                            .padding(.horizontal)
                        // 2 of Purple Striped Diamonds
                        CardView(card: gamePreviewModel.cards[40])
                            .aspectRatio(2/3, contentMode: .fit)
                            .padding(.horizontal)
                    }.padding(EdgeInsets(top: 10.0, leading: 0, bottom: 10.0, trailing: 0.0))
                    VStack {
                        // 3 of Red Solid Ovals
                        CardView(card: gamePreviewModel.cards[74])
                            .aspectRatio(2/3, contentMode: .fit)
                            .padding(.horizontal)
                        // 1 of Purple Solid Diamond
                        CardView(card: gamePreviewModel.cards[15])
                            .aspectRatio(2/3, contentMode: .fit)
                            .padding(.horizontal)
                    }.padding(EdgeInsets(top: 10.0, leading: 0, bottom: 10.0, trailing: 0.0))
                }
            }
        }
    }
}
