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
        GeometryReader { geometry in
            let scaleFactor = geometry.size.width / 100.0
            ZStack(alignment: .topTrailing) {
                ZStack {
                    let shape = RoundedRectangle(cornerRadius: Constants.cornerRadius * scaleFactor )
                    shape.fill().foregroundColor(.white)
                    shape
                        .strokeBorder(lineWidth: Constants.borderThickness * scaleFactor)
                        .foregroundColor(card.selected ? .red : .gray)
                        .opacity(card.selected ? 1.0 : 0.2)
                    drawContent(card: card, scaledBy: scaleFactor)
                }
                if (card.selected) {
                    selectionBadge(scaledBy: scaleFactor)
                }
            }
        }
    }
    
    func drawContent(card: SetGameViewModel.Card, scaledBy scaleFactor: CGFloat) -> some View {
        return VStack() {
            ForEach(0 ..< card.numberOfShapes, id: \.self) { ix in
                let symbol = CardSymbolPainter(shapeType: card.shape)
                let outlineSymbol = symbol
                    .stroke(lineWidth: Constants.shapeBorderThickness * scaleFactor)
                    .fill(card.color.uiColor)
                    .aspectRatio(symbol.aspect, contentMode: .fit)
                let filledSymbol = symbol
                    .fill(card.color.uiColor)
                    .aspectRatio(symbol.aspect, contentMode: .fit)
                ZStack {
                    switch card.shading {
                    case .SolidShading:
                        filledSymbol.opacity(Constants.fillOpacity)
                        outlineSymbol
                    case .OpenShading:
                        outlineSymbol
                    case .StripedShading:
                        StripedRectangle(
                            rotation: Angle(degrees: Constants.stripeAngle ),
                            fillColor: card.color.uiColor,
                            spacing: Constants.stripeSpacing,
                            count: Constants.stripeCount)
                        .mask {
                            filledSymbol
                        }
                        outlineSymbol
                    }
                }.padding(.vertical, symbol.vPad * scaleFactor)
            }
        }.padding(15.0 * scaleFactor)
    }

    func selectionBadge(scaledBy scaleFactor: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill().foregroundColor(.white)
                .frame(width: 32 * scaleFactor, height: 32 * scaleFactor)
            Image(systemName: "checkmark.circle.fill")
                .font(scaleFactor < 0.5 ?  .body : .title)
                .foregroundColor(.green)
                .padding(2.0 * scaleFactor)
        }.padding(5.0 * scaleFactor)
    }
    
    struct Constants {
        static let cornerRadius: CGFloat = 10.0
        static let borderThickness: CGFloat = 4.0
        static let shapeBorderThickness: CGFloat = 3.0
        static let aspectRatio: CGFloat = 2.2
        static let fillOpacity: CGFloat = 0.7
        static let stripeAngle: CGFloat = 20.0
        static let stripeSpacing: CGFloat = 1
        static let stripeCount = 8
    }
}

struct StripedRectangle: View {
    
    var rotation: Angle
    var fillColor: Color
    
    /** Ratio of stripes to spaces. eg 1 means the stripes are equal to the spaces */
    var spacing: CGFloat = 1
    var count: Int = 6
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let cr = cos(rotation.radians)
            let sr = sin(rotation.radians)
            let stripeWidth = w / (CGFloat(count) + (CGFloat(count - 1) * spacing) - spacing)
            let rotatedWidth = cr * w + sr * h
            let rotatedHeight = cr * h + sr * w
            HStack(spacing: stripeWidth * spacing) {
                ForEach(0 ..< count, id:\.self) { ix in
                    Rectangle()
                        .fill(fillColor)
                        .frame(width: stripeWidth, height: rotatedHeight)
                }
            }.border(.blue)
            .frame(width: rotatedWidth, height: rotatedHeight, alignment: .center)
            .offset(CGSize(width: (w - rotatedWidth) / 2.0, height: (h - rotatedHeight) / 2.0))
            .rotationEffect(rotation)
        }
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
    
    var vPad: CGFloat {
        shapeType == .Oval ? 3.0 : 0.0
    }
    
    var aspect: CGFloat {
        shapeType == .Squiggle ? CardView.Constants.aspectRatio * 0.8 : CardView.Constants.aspectRatio
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
            return Color.teal
        case .Purple:
            return Color.indigo
        case .Red:
            return Color.orange
        }
    }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let a = SetGameViewModel.Card(id: 0, numberOfShapes: 1, shading: .StripedShading, shape: .Oval, color: .Red, selected: false)
        let b = SetGameViewModel.Card(id: 1, numberOfShapes: 2, shading: .StripedShading, shape: .Oval, color: .Green, selected: false)
        let c = SetGameViewModel.Card(id: 2, numberOfShapes: 3, shading: .OpenShading, shape: .Oval, color: .Purple, selected: true)
        let d = SetGameViewModel.Card(id: 3, numberOfShapes: 1, shading: .StripedShading, shape: .Squiggle, color: .Red, selected: false)
        let e = SetGameViewModel.Card(id: 4, numberOfShapes: 1, shading: .SolidShading, shape: .Oval, color: .Red, selected: true)
        let f = SetGameViewModel.Card(id: 5, numberOfShapes: 2, shading: .StripedShading, shape: .Oval, color: .Green, selected: false)
        let g = SetGameViewModel.Card(id: 6, numberOfShapes: 3, shading: .SolidShading, shape: .Squiggle, color: .Purple, selected: true)
        let h = SetGameViewModel.Card(id: 7, numberOfShapes: 1, shading: .StripedShading, shape: .Oval, color: .Red, selected: false)
        let i = SetGameViewModel.Card(id: 8, numberOfShapes: 3, shading: .StripedShading, shape: .Oval, color: .Red, selected: false)
        let j = SetGameViewModel.Card(id: 9, numberOfShapes: 2, shading: .StripedShading, shape: .Oval, color: .Green, selected: false)
        let k = SetGameViewModel.Card(id: 10, numberOfShapes: 3, shading: .OpenShading, shape: .Squiggle, color: .Purple, selected: false)
        let l = SetGameViewModel.Card(id: 11, numberOfShapes: 1, shading: .StripedShading, shape: .Oval, color: .Red, selected: true)
        let items = [a, b, c, d, e, f, g, h, i, j, k, l]
//        let items = [a, b, c]
        ZStack {
            Rectangle().fill(.gray).opacity(0.3).ignoresSafeArea()
            AspectVGrid(items: items, aspectRatio: 2/3) { card in
                CardView(card: card).padding(3.0)
            }
        }
    }
}
