//
//  HomeViewUITests.swift
//  TriviaAppUITests
//
//  Created by Tino on 21/12/2022.
//

import XCTest

final class HomeViewUITests: XCTestCase {
    let app = TriviaAppApp()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSettingTriviaProperties() throws {
        try app.triviaCategoryPicker().select(.art)
        try app.triviaCategoryPicker().select(.videoGames)
        for _ in 0 ..< 5 {
            try app.numberOfQuestionsButton(.increment).tap()
        }
        for _ in 0 ..< 5 {
            try app.numberOfQuestionsButton(.decrement).tap()
        }
        try app.difficultyPicker().select(.hard)
        try app.questionTypePicker().select(.any)
    }
}
