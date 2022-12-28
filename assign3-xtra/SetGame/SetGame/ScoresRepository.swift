//
//  ScoresRepository.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 27/12/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import Foundation

class ScoresRepository {
    
    struct Constants {
        static let HighScoresKey = "HighScores"
    }
    
    func setScore(_ score: Int) {
        let scores: [Int] = getScores()
        let scoresIncludingNew = scores + [ score ]
        let scoresSorted = scoresIncludingNew.sorted(by: >)
        let firstThree = Array<Int>( scoresSorted.prefix(3) )
        UserDefaults.standard.set(firstThree, forKey: Constants.HighScoresKey)
    }
    
    func getScores() -> [ Int ] {
        return UserDefaults.standard.array(forKey: Constants.HighScoresKey) as? [Int] ?? Array<Int>()
    }
}
