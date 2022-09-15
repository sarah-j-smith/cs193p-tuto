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
            Text(card.content).font(.largeTitle)
        }
    }
    
    struct Constants {
        static let cornerRadius: CGFloat = 10.0
        static let borderThickness: CGFloat = 2.0
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
