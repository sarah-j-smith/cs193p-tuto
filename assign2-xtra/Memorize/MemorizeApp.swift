//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Sarah Smith on 7/8/2022.
//

import SwiftUI

@main
struct MemorizeApp: App {
    
    private let memoryGame = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: memoryGame)
        }
    }
}
