//
//  HomeViewUITests.swift
//  TriviaAppUITests
//
//  Created by Tino on 21/12/2022.
//

import XCTest

final class HomeViewUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetTriviaSettings() throws {
        
        let collectionViewsQuery = XCUIApplication().collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["History"]/*[[".cells.buttons[\"History\"]",".buttons[\"History\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Books"]/*[[".cells.buttons[\"Books\"]",".buttons[\"Books\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
    }
}
