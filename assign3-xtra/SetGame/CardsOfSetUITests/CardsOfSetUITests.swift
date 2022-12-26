//
//  CardsOfSetUITests.swift
//  CardsOfSetUITests
//
//  Created by Sarah Smith on 5/12/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import XCTest

final class CardsOfSetUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testControls() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests", "useShortDeck"]
        app.launch()

        let timeout: Double = 2

        let c1Card = app.otherElements["Card_1"]
        let c2Card = app.otherElements["Card_2"]
        let c3Card = app.otherElements["Card_3"]

        let found = c1Card.waitForExistence(timeout: timeout)
        
        XCTAssert(found)
        c1Card.tap()
        c2Card.tap()
        c3Card.tap()

        let hintButton = app.buttons["Hint"]
        XCTAssert(hintButton.exists)
        XCTAssert(hintButton.isEnabled)
        XCTAssert(hintButton.isHittable)

        let deal3Button = app.buttons["Deal 3"]
        XCTAssert(deal3Button.exists)
        XCTAssert(deal3Button.isEnabled)
        XCTAssert(deal3Button.isHittable)

        let settingsButton = app.buttons["Settings"]
        XCTAssert(settingsButton.exists)
        XCTAssert(settingsButton.isEnabled)
        XCTAssert(settingsButton.isHittable)

        let newGameButton = app.buttons["New Game"]
        XCTAssert(newGameButton.exists)
        XCTAssert(newGameButton.isEnabled)
        XCTAssert(newGameButton.isHittable)

        let evaluationPanelButton = app.buttons["Evaluation_Panel"]
        let foundPanel = evaluationPanelButton.waitForExistence(timeout: timeout)
        XCTAssertTrue(foundPanel)
        XCTAssertTrue(evaluationPanelButton.isHittable)
        XCTAssertEqual(evaluationPanelButton.label, "Not a Match!")
    }

    func testGameWin() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests", "useShortDeck"]
        app.launch()

        let timeout: Double = 2

        for ix in 0 ..< 6 {
            
            let c1 = ix * 3
            let c2 = ix * 3 + 1
            let c3 = ix * 3 + 2
            
            let c1Card = app.otherElements["Card_\(c1)"]
            let c2Card = app.otherElements["Card_\(c2)"]
            let c3Card = app.otherElements["Card_\(c3)"]

            let found = c1Card.waitForExistence(timeout: timeout)
            
            XCTAssert(found)
            c1Card.tap()
            c2Card.tap()
            c3Card.tap()
            
            let evaluationPanelButton = app.buttons["Evaluation_Panel"]
            let foundPanel = evaluationPanelButton.waitForExistence(timeout: timeout)
            XCTAssertTrue(foundPanel)
            XCTAssertEqual(evaluationPanelButton.label, "It's a Match!")
            evaluationPanelButton.tap()
        }
        
        let deal3Button = app.buttons["Deal 3"]
        XCTAssert(deal3Button.exists)
        XCTAssertFalse(deal3Button.isEnabled)
        
        app.otherElements["Card_17"].tap()
        
        let winPanel = app.buttons["Game_End_Win"]
        let foundWinPanel = winPanel.waitForExistence(timeout: timeout)
        
        XCTAssertTrue(foundWinPanel)
        winPanel.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launchArguments = ["isRunningUITests", "useShortDeck"]
                app.launch()
            }
        }
    }
}
