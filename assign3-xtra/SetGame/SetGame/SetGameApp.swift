//
//  SetGameApp.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//

import SwiftUI

@main
struct SetGameApp: App {
    
    private let setGame = SetGameViewModel.createGame()
    
    var body: some Scene {
        WindowGroup {
            ContentView(game: setGame)
        }
    }
}
