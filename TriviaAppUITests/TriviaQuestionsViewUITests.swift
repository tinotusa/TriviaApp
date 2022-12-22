//
//  TriviaQuestionsViewUITests.swift
//  TriviaAppUITests
//
//  Created by Tino on 22/12/2022.
//

import XCTest

final class TriviaQuestionsViewUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("-testing-quiz")
        print(CommandLine.arguments)
        app.launch()
        app.buttons["Start trivia"].tap()
    }
    
    func testTapAnswerButton() {
        selectRandomAnswer()
    }
    
    func testTapContinueButtonWithoutAnswer() {
        let continueButton = app.buttons["Continue button"]
        XCTAssertFalse(continueButton.isEnabled, "Expected the continue button to be disabled since no answer has been selected.")
    }
    
    func testAnswerAndContinue() {
        selectRandomAnswer()
        let continueButton = app.buttons["Continue button"]
        continueButton.tap()
        XCTAssertFalse(continueButton.isEnabled, "Expected the continue button to be disabled since it was tapped and moved on to the next question.")
    }
    
    func testTapQuitButton() {
        let quitButton = app.buttons["Quit trivia"]
        quitButton.tap()
        let quitConfirmationDialogButton = app.buttons["Confirmation Quit"]
        XCTAssertTrue(quitConfirmationDialogButton.exists, "Expected the quit confirmation dialog button to exist after tapping quit trivia button.")
        quitConfirmationDialogButton.tap()
        let startTriviaButton = app.buttons["Start trivia"]
        XCTAssertTrue(startTriviaButton.exists, "Expected the start trivia button to exist after quitting trivia.")
    }
    
    func testTapQuitButtonThenContinue() {
        let quitButton = app.buttons["Quit trivia"]
        quitButton.tap()
        
        let continueConfirmationDialogButton = app.buttons["Confirmation continue"]
        XCTAssertTrue(continueConfirmationDialogButton.exists, "Expected the quit confirmation dialog button to exist after tapping quit trivia button.")
        continueConfirmationDialogButton.tap()
        
        let continueButton = app.buttons["Continue button"]
        XCTAssertTrue(continueButton.exists, "Expected the continue button to exist after continuing with the trivia.")
        XCTAssertFalse(continueButton.isEnabled, "Expected the continue button to be disabled since no answer has been selected in this test.")
    }
    
    func testTapHint() {
        let hintButton = app.buttons["Hint button"]
        XCTAssertTrue(hintButton.isEnabled, "Expected hint button to be enabled.")
        hintButton.tap()
        hintButton.tap()
        hintButton.tap()
        XCTAssertFalse(hintButton.isEnabled, "Expected hint button to be disabled since it has been tapped three times (the max hint amount).")
    }
    
    func testAnswerAllQuestions() {
        for _ in 0 ..< 10 {
            selectRandomAnswer()
            tapContinueButton()
        }
        let continueButton = app.buttons["Continue button"]
        XCTAssertTrue(continueButton.exists, "Expected the continue button on TriviaResultsView to exist.")
        XCTAssertTrue(continueButton.isEnabled, "Expected the continue button to be enabled.")
    }
}

// MARK: Helper functions
private extension TriviaQuestionsViewUITests {
    enum TriviaType: String {
        case multiple = "Multiple choice"
        case boolean = "True or false"
    }
    
    func selectRandomAnswer() {
        let questionType = app.staticTexts["Question type label"]
        var answerCount = 0
        let triviaType = TriviaType(rawValue: questionType.label)!
        switch triviaType {
        case .boolean: answerCount = 2
        case .multiple: answerCount = 4
        }
        let randomChoice = Int.random(in: 0 ..< answerCount)
        let answerButton = app.buttons["Answer button\(randomChoice)"]
        XCTAssertTrue(answerButton.isEnabled, "Expected the answer button to be enabled")
        
        answerButton.tap()
    }
    
    func tapContinueButton() {
        let continueButton = app.buttons["Continue button"]
        XCTAssertTrue(continueButton.exists, "Expected continue button to exist")
        XCTAssertTrue(continueButton.isEnabled, "Expected continue button to be enabled so that the quiz can continue.")
        continueButton.tap()
    }
}
