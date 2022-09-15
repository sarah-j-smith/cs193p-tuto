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
            shape.strokeBorder(lineWidth: Constants.borderThickness)
            
            switch card.shape {
            case .Diamond:
                 Diamond()
                    .stroke(lineWidth: 3.0)
                    .fill(.green)
                    .aspectRatio(3/2, contentMode: .fit)
                    .padding(20.0)
            case .Oval:
                 Capsule()
                    .stroke(lineWidth: 3.0)
                    .fill(.green)
                    .aspectRatio(3/2, contentMode: .fit)
                    .padding(20.0)
            case .Squiggle:
                 WigglyLine()
                    .stroke(lineWidth: 3.0)
                    .fill(.green)
                    .aspectRatio(3/2, contentMode: .fit)
                    .padding(20.0)
            }
        }
    }
    
    struct Constants {
        static let cornerRadius: CGFloat = 10.0
        static let borderThickness: CGFloat = 2.0
    }
}

struct Diamond: Shape {
    
    func path(in rect: CGRect) -> Path {
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
}

struct WigglyLine: Shape {
    
    func path(in rect: CGRect) -> Path {
        // Wavy line is made up of 4 equal arcs - so divide width by 4
        let arcWidth = (rect.width/CGFloat(4.0))
        // Wavy line inflection is at 45 degrees
        let inflect = Angle(degrees: 45)
        let arcRadius = arcWidth / sin(inflect.radians)
        let insetHeight = arcRadius - arcWidth
        let inCurveYCenterOffset = insetHeight * 2 - arcRadius
        var p = Path()
        p.move(to: CGPoint(x: 0, y: insetHeight))
        p.addArc(center: CGPoint(x: arcWidth, y: arcRadius), radius: arcRadius, startAngle: Angle(degrees: 225.0), endAngle: Angle(degrees: 315.0), clockwise: false)
        p.addArc(center: CGPoint(x: arcWidth + rect.midX, y: inCurveYCenterOffset), radius: arcRadius, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: true)
        p.addLine(to: CGPoint(x: rect.width, y: rect.height - CGFloat(2 * insetHeight)))
        p.addArc(center: CGPoint(x: arcWidth + rect.midX, y: rect.height - arcRadius), radius: arcRadius, startAngle: Angle(degrees: 45), endAngle: Angle(degrees: 135), clockwise: false)
        p.addArc(center: CGPoint(x: arcWidth, y: rect.height - inCurveYCenterOffset), radius: arcRadius, startAngle: Angle(degrees: 315.0), endAngle: Angle(degrees: 225.0), clockwise: true)
        p.addLine(to: CGPoint(x: 0, y: insetHeight))
        return p
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let gamePreviewModel = SetGameViewModel()
        CardView(card: gamePreviewModel.cards[0])
            .aspectRatio(2/3, contentMode: .fit)
            .padding(100.0)
    }
}
