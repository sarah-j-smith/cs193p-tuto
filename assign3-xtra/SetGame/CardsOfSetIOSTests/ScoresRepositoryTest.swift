//
//  ScoresRepositoryTest.swift
//  CardsOfSet
//
//  Created by Sarah Smith on 27/12/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//


import XCTest

final class ScoresRepositoryTest: XCTestCase {
    
    var scoresRepository: ScoresRepository?
    
    
    override func setUpWithError() throws {
        UserDefaults.standard.set(nil, forKey: ScoresRepository.Constants.HighScoresKey)
        scoresRepository = ScoresRepository()
    }

    override func tearDownWithError() throws {
        scoresRepository = nil
    }

    func testSetScore() throws {
        let sut = try XCTUnwrap(scoresRepository)
        
        sut.setScore(55)
        
        let result = UserDefaults.standard.array(forKey: ScoresRepository.Constants.HighScoresKey)
        let ary = try XCTUnwrap(result as? Array<Int>)
        
        XCTAssertEqual([ 55 ], ary)
    }
    
    func testOnlyStoresTopThreeScores() throws {
        let sut = try XCTUnwrap(scoresRepository)

        sut.setScore(70)
        sut.setScore(85)
        sut.setScore(98)
        sut.setScore(109)
        
        let result = UserDefaults.standard.array(forKey: ScoresRepository.Constants.HighScoresKey)
        let ary = try XCTUnwrap(result as? Array<Int>)
        
        XCTAssertEqual([ 109, 98, 85 ], ary)
    }
    
    func testGetScores() throws {
        let sut = try XCTUnwrap(scoresRepository)

        let ary = sut.getScores()
        XCTAssertEqual(ary, [])
        
        UserDefaults.standard.set([ 4, 5, 6 ], forKey: ScoresRepository.Constants.HighScoresKey)
        let ary2 = sut.getScores()
        XCTAssertEqual(ary2, [ 4, 5, 6 ])
    }
    
}
