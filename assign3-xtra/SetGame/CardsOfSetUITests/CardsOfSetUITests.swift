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

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["isRunningUITests"]
        app.launch()

        let timeout: Double = 2

        for ix in 0 ..< 27 {
            
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
            
            let evaluationPanelButton = app/*@START_MENU_TOKEN@*/.buttons.containing(.image, identifier:"Evaluation_Panel").element/*[[".buttons.containing(.staticText, identifier:\"It's a Match!\").element",".buttons.containing(.staticText, identifier:\"Evaluation_Panel\").element",".buttons.containing(.image, identifier:\"It's a Match!\").element",".buttons.containing(.image, identifier:\"Evaluation_Panel\").element"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
            let foundPanel = evaluationPanelButton.waitForExistence(timeout: timeout)
            
            XCTAssertTrue(foundPanel)
            evaluationPanelButton.tap()
        }
        
        app.otherElements["Card_80"].tap()
        
        let winPanel = app.buttons.containing(.image, identifier: "Geme_End_Win").element
        let foundWinPanel = winPanel.waitForExistence(timeout: timeout)
        
        XCTAssertTrue(foundWinPanel)
        winPanel.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
