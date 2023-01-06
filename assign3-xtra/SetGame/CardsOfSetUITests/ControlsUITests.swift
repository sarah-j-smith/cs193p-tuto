//
//  ControlsUITests.swift
//  CardsOfSetUITests
//
//  Created by Sarah Smith on 21/12/2022.
//  Copyright © 2022 Smithsoft. All rights reserved.
//

import XCTest

final class ControlsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHintButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests", "useShortDeck"]
        app.launch()

        let timeout: Double = 2

        let c3Card = app.otherElements["Card_3"]

        let found = c3Card.waitForExistence(timeout: timeout)
        XCTAssert(found)
        
        let hintButton = app.buttons["Hint"]
        hintButton.tap()

        let hintPanelButton = app.buttons["Hint_Panel"]
        let foundPanel = hintPanelButton.waitForExistence(timeout: timeout)
        XCTAssertTrue(foundPanel)
        XCTAssertTrue(hintPanelButton.isHittable)
        XCTAssertEqual(hintPanelButton.label, "The current 12 cards dealt has 13 sets to find! Here's one to get you started.")
    }
    
    func testDeal3Button() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests", "useShortDeck"]
        app.launch()

        let timeout: Double = 2

        let c0Card = app.otherElements["Card_0"]
        let c1Card = app.otherElements["Card_1"]
        let c2Card = app.otherElements["Card_2"]

        let found = c1Card.waitForExistence(timeout: timeout)
        
        XCTAssert(found)
        c0Card.tap()
        c1Card.tap()
        c2Card.tap()

        let deal3Button = app.buttons["Deal 3"]
        XCTAssert(deal3Button.exists)
        XCTAssert(deal3Button.isEnabled)
        XCTAssert(deal3Button.isHittable)

        let evaluationPanel = app.otherElements["Evaluation_Panel"]
        let foundPanel = evaluationPanel.waitForExistence(timeout: timeout)
        XCTAssertTrue(foundPanel)
        XCTAssertEqual(evaluationPanel.label, "It's a Match!")
        
        let evaluationPanelButton = app.buttons["Dismiss_OK"]
        evaluationPanelButton.tap()
        
        deal3Button.tap()

        let notExists = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "exists == true"))
        let cardDisappear = expectation(for: notExists, evaluatedWith: c2Card)
        wait(for: [cardDisappear], timeout: timeout)
        
        XCTAssertFalse(c2Card.exists)
    }
    
    func testSettingsButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests", "useShortDeck"]
        app.launch()

        let timeout: Double = 2

        let c1Card = app.otherElements["Card_1"]

        let found = c1Card.waitForExistence(timeout: timeout)
        XCTAssertTrue(found)

        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()

        let aboutPanelButton = app.buttons["About_Panel"]
        let foundPanel = aboutPanelButton.waitForExistence(timeout: timeout)
        XCTAssertTrue(foundPanel)
        XCTAssertTrue(aboutPanelButton.isHittable)
        XCTAssertEqual(aboutPanelButton.label, "About Cards of Set")
    }
    
    func testNewGameButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests", "useShortDeck"]
        app.launch()

        let timeout: Double = 2
        
        for ix in 0 ..< 3 {
            
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
            
            let evaluationPanel = app.otherElements["Evaluation_Panel"]
            let foundPanel = evaluationPanel.waitForExistence(timeout: timeout)
            XCTAssertTrue(foundPanel)
            
            let evaluationPanelButton = app.buttons["Dismiss_OK"]
            evaluationPanelButton.tap()
        }
        
        // Start deck of 18, deal 12 - clear out 3 sets of 3 = 9; now only 9 in tableau
        let cardsPredicate = NSPredicate(format: "identifier beginswith 'Card_'")

        let c9 = app.otherElements["Card_9"]
        let foundC9 = c9.waitForExistence(timeout: timeout)
        XCTAssertTrue(foundC9)
        c9.tap()

        let match = cardsPredicate.evaluate(with: c9)
        XCTAssertTrue(match)
        
        let c8 = app.otherElements["Card_8"]
        let notExists = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "exists == true"))
        let cardDisappear = expectation(for: notExists, evaluatedWith: c8)
        wait(for: [cardDisappear], timeout: timeout)
        
        // Start deck of 18, deal 12 - clear out 3 sets of 3 = 9; now only 9 in tableau
        let cardCountBefore = app.otherElements.matching(cardsPredicate).count
        XCTAssertEqual(cardCountBefore, 9)

        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        
        // Start deck of 18, deal 12 - clear out 3 sets of 3 = 9; now only 9 in tableau
        let cardCountAfter = app.otherElements.matching(cardsPredicate).count
        XCTAssertEqual(cardCountAfter, 12)
    }
}
