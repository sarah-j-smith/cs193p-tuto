//
//  Cardify.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 8/11/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import SwiftUI

struct Cardify: ViewModifier {
    
    var isSelected: Bool
    var scaleFactor: CGFloat
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                let shape = RoundedRectangle(cornerRadius: Constants.cornerRadius * scaleFactor )
                shape.fill().foregroundColor(.white)
                shape
                    .strokeBorder(lineWidth: Constants.borderThickness * scaleFactor)
                    .foregroundColor(isSelected ? .red : .gray)
                    .opacity(isSelected ? 1.0 : 0.4)
                content
            }
            if (isSelected) {
                selectionBadge(scaledBy: scaleFactor).transition(.scale.animation(.spring()))
            }
        }
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
    }
}

extension View {
    func cardify(isSelected selected: Bool, scaleFactor scale: CGFloat) -> some View {
        return self.modifier(Cardify(isSelected: selected, scaleFactor: scale))
    }
}
