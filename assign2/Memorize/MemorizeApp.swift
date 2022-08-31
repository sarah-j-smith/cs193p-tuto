//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Sarah Smith on 7/8/2022.
//

import SwiftUI

@main
struct MemorizeApp: App {
    
    let memoryGame = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: memoryGame)
        }
    }
}
