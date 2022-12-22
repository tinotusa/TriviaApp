//
//  HomeViewUITests.swift
//  TriviaAppUITests
//
//  Created by Tino on 21/12/2022.
//

import XCTest

final class HomeViewUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    enum Category: String {
        case art = "Art"
        case videoGames = "Video games"
    }
    
    func testSetTriviaCategory() throws {
        let categoryPicker = app.buttons["Category Picker"]
        let category = Category.art.rawValue
        
        XCTAssertTrue(categoryPicker.exists, "Expected the category picker to exist.")
        categoryPicker.tap()
        
        let artButton = app.buttons[category]
        artButton.tap()
        
        XCTAssertTrue(app.staticTexts[category].exists, "Expected art category to be set.")
    }
    
    func testIncrementButton() throws {
        let incrementButton = app.buttons["Stepper increment"]
        XCTAssertTrue(incrementButton.exists, "Expected the increment button to exist.")
        
        let stepperTextField = app.textFields["Stepper textField"]
        let textFieldValue = try XCTUnwrap(stepperTextField.value as? String, "Expected to unwrap stepper textfield value.")
        let value = try XCTUnwrap(Int(textFieldValue), "Expected to unwrap text field value to Int.")
        
        let tapCount = 5
        let expectedValue = "\(value + tapCount)"
        for _ in 0 ..< tapCount {
            incrementButton.tap()
        }
        
        XCTAssertEqual(stepperTextField.value as! String, expectedValue, "Expected stepper text field value to be \(expectedValue)")
    }
    
    func testDecrementButton() throws {
        let decrementButton = app.buttons["Stepper decrement"]
        XCTAssertTrue(decrementButton.exists, "Expected the increment button to exist.")
        let stepperTextField = app.textFields["Stepper textField"]

        for _ in 0 ..< 5 {
            decrementButton.tap()
        }
        let expectedValue = "5"
        XCTAssertEqual(stepperTextField.value as! String, expectedValue, "Expected stepper text field value to be \(expectedValue).")
    }
    
    func testSetNumberOfQuestionsWithKeyboard() throws {
        let stepperTextField = app.textFields["Stepper textField"]
        XCTAssertTrue(stepperTextField.exists, "Expected the stepper text field to exist.")
        let currentValue = stepperTextField.value as! String
        
        let value = "15"
        
        // this taps the end of the text field
        let test = stepperTextField.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
        test.tap()
//        stepperTextField.tap()
        
        stepperTextField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count))
        stepperTextField.typeText(value)
        XCTAssertEqual(stepperTextField.value as! String, value, "Expected stepper text field value to be \(value)")
    }

    enum QuestionType: String {
        case any = "Any"
        case multipleChoice = "Multiple choice"
        case trueOrFalse = "True or false"
    }
    
    func testSetQuestionType() throws {
        let questionTypePicker = app.buttons["Question type picker"]
        questionTypePicker.tap()
        
        let questionType = QuestionType.multipleChoice.rawValue
        let typeButton = app.buttons[questionType]
        XCTAssertTrue(typeButton.exists, "Expected the \(questionType) button to exist.")
        
        typeButton.tap()
        let questionTypeExists = app.staticTexts[questionType].exists
        XCTAssertTrue(questionTypeExists, "Expected \(questionType) to be set.")
    }
    
    func testStartTriviaButton() {
        let startButton = app.buttons["Start Trivia"]
        XCTAssertTrue(startButton.isEnabled, "Expected the start trivia button to be enabled.")
    }
    
    func testTapCreditsButton() {
        let creditsButton = app.buttons["Credits button"]
        XCTAssertTrue(creditsButton.exists, "Expected the credits button to exist.")
        creditsButton.tap()
        let acknowledgements = app.staticTexts["Acknowledgements title"]
        XCTAssertTrue(acknowledgements.exists, "Expected acknowledgements title to exist.")
        
        let closeButton = app.buttons["Close button"]
        XCTAssertTrue(closeButton.exists, "Expected close button to exist in the sheet")
        closeButton.tap()
        
        let triviaTitle = app.staticTexts["Trivia"]
        XCTAssertTrue(triviaTitle.exists, "Expected the trivia title to exist since credit sheet closed.")
    }
}
