//
//  QuestionsViewModelTests.swift
//  TriviaAppTests
//
//  Created by Tino on 19/12/2022.
//

import XCTest
import SwiftOpenTDB
@testable import TriviaApp

final class QuestionsViewModelTests: XCTestCase {
    var viewModel: QuestionsViewModel!
    var mockOpenTDB: MockOpenTDB!
    
    override func setUp() {
        mockOpenTDB = MockOpenTDB(triviaConfig: .default)
        viewModel = QuestionsViewModel(triviaConfig: .default, openTDB: mockOpenTDB)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDefaultData() async {
        XCTAssertEqual(viewModel.currentQuestionIndex, 0, "Expected current index to be 0.")
        XCTAssertFalse(viewModel.isTriviaRoundOver, "Expected isTriviaRoundOver to be false.")
        XCTAssertTrue(viewModel.questions.isEmpty, "Expected to have 0 questions in the view model.")
        XCTAssertNil(viewModel.selectedAnswer, "Expected selected answer to be nil.")
        XCTAssertTrue(viewModel.hiddenAnswers.isEmpty, "Expected to have 0 hidden answers in the view model.")
        XCTAssertFalse(viewModel.showingAlert, "Expected showing alert to be false.")
        XCTAssertNil(viewModel.alert, "Expected alert to be nil.")
        let question = await viewModel.currentQuestion
        XCTAssertNil(question, "Expected current question to return nil.")
    }
    
    func testCurrentQuestion() async throws {
        try await viewModel.getQuestions()
        let question  = await viewModel.currentQuestion
        XCTAssertNotNil(question, "Expected to have a non nil answer.")
    }
    
    func testIsAnswerHidden() async throws {
        try await viewModel.getQuestions()
        _ = await viewModel.currentQuestion
        _ = await viewModel.showHint()
        _ = await viewModel.showHint()
        _ = await viewModel.showHint()
        XCTAssertTrue(viewModel.hintsDisabled, "Expected to have hints disabled after calling showHint 3 times.")
        XCTAssertEqual(viewModel.hiddenAnswers.count, 3, "Expected to have 3 hidden answers.")
        let isHidden = viewModel.isAnswerHidden(answer: "Robin Walker")
        XCTAssertTrue(isHidden, "Expected to have the answer hidden.")
    }
    
    func testIsAnswerHiddenWithNoExtraHintsLeft() async throws {
        try await viewModel.getQuestions()
        _ = await viewModel.currentQuestion
        _ = await viewModel.showHint()
        _ = await viewModel.showHint()
        _ = await viewModel.showHint()
        let showedHint = await viewModel.showHint()
        XCTAssertFalse(showedHint, "Expected 4th showHint call to return false.")
        XCTAssertTrue(viewModel.hintsDisabled, "Expected hints disabled to be true.")
    }
    
    func testBooleanQuestionsHaveNoHints() async throws {
        try await viewModel.getQuestions()
        await viewModel.nextQuestion()
        await viewModel.nextQuestion() // this question is a boolean
        _ = await viewModel.currentQuestion
    
        let showedHint = await viewModel.showHint()
        XCTAssertFalse(showedHint, "Expected no hint to be shown.")
    }
    
    func testClearIncorrectAnswers() async throws {
        try await viewModel.getQuestions()
        _ = await viewModel.currentQuestion
        _ = await viewModel.showHint()
        XCTAssertEqual(viewModel.hiddenAnswers.count, 1, "Expected to have 1 hidden answer.")
        await viewModel.resetQuestionState()
        XCTAssertTrue(viewModel.hiddenAnswers.isEmpty, "Expected to have empty hidden answers.")
    }
    
    func testNextQuestion() async throws {
        try await viewModel.getQuestions()
        _ = await viewModel.currentQuestion
        await viewModel.nextQuestion()
        let question = await viewModel.currentQuestion
        XCTAssertNotNil(question, "Expected next question to be non nil.")
        XCTAssertEqual(viewModel.currentQuestionIndex, 1, "Expected the current questions index to be 1.")
    }
    
    func testResetQuestion() async {
        let didSuccessfullyReset = await viewModel.resetQuestions()
        XCTAssertTrue(didSuccessfullyReset, "Expected to have successfully reset the questions")
        XCTAssertNil(viewModel.alert, "Expected alert to be nil.")
    }
    
    func testResetQuestionThrows() async {
        mockOpenTDB.resetTokenError = .invalidAPIResponse(code: ResponseCode(rawValue: 4)!)
        let didSuccessfullyReset = await viewModel.resetQuestions()
        XCTAssertFalse(didSuccessfullyReset, "Expected false since mock trivia api has error set.")
    }
    
    func testEndOfTrivia() async throws {
        try await viewModel.getQuestions()
        for _ in viewModel.questions {
            await viewModel.nextQuestion()
        }
        await viewModel.nextQuestion()
        XCTAssertTrue(viewModel.isTriviaRoundOver, "Expected is trivia round over to be true.")
    }
}

// MARK: - submitAnswer tests
extension QuestionsViewModelTests {
    func testSubmitWithNilAnswer() async {
        let success = await viewModel.submitAnswer()
        XCTAssertFalse(success, "Expected false since no answer has been set.")
    }
    
    func testSubmitAnswerWithNoQuestionsSet() async {
        viewModel.selectedAnswer = "some answer"
        let isSuccessful = await viewModel.submitAnswer()
        XCTAssertFalse(isSuccessful, "Expected question submission to be false.")
    }
    
    func testSubmitWithCorrectAnswer() async throws {
        try await viewModel.getQuestions()
        viewModel.selectedAnswer = "Mike Harrington"
        let success = await viewModel.submitAnswer()
        XCTAssertTrue(success, "Expected true since the answer is correct.")
        XCTAssertEqual(viewModel.triviaResult.score, 1, "Expected trivia result score to be 1.")
    }
    
    func testSubmitWithIncorrectAnswer() async throws {
        try await viewModel.getQuestions()
        viewModel.selectedAnswer = "not correct"
        XCTAssertTrue(viewModel.hasSelectedAnswer, "Expected selected answer to be true.")
        let success = await viewModel.submitAnswer()
        XCTAssertFalse(success, "Expected to get false since the answer is not correct.")
        XCTAssertEqual(viewModel.triviaResult.wrongQuestions.count, 1, "Expected wrong questions array to be 1.")
    }
}

// MARK: - showHint tests
extension QuestionsViewModelTests {
    func testShowHint() async throws {
        try await viewModel.getQuestions()
        let question = await viewModel.currentQuestion
        XCTAssertNotNil(question)
        XCTAssertFalse(viewModel.hintsDisabled, "Expected hints to not be disabled.")
        _ = await viewModel.showHint()
        XCTAssertEqual(viewModel.hiddenAnswers.count, 1, "Expected to have 1 hidden answer.")
    }
    
    func testShowHintWithoutQuestions() async {
        let showedHint = await viewModel.showHint()
        XCTAssertFalse(showedHint, "Expected false since no hint was shown.")
    }
    
    func testShowHintRemovesSelectedAnswer() async throws {
        try await viewModel.getQuestions()
        let question = await viewModel.currentQuestion
        viewModel.selectedAnswer = question!.incorrectAnswers.first!
        _ = await viewModel.showHint()
        _ = await viewModel.showHint()
        _ = await viewModel.showHint()
        XCTAssertNil(viewModel.selectedAnswer, "Expected selected answer to be nil.")
    }
}

// MARK: - getQuestions tests
extension QuestionsViewModelTests {
    func testGetQuestions() async throws {
        try await viewModel.getQuestions()
        XCTAssertEqual(viewModel.questions.count, 10, "Expected to get 10 questions back.")
    }
    
    func testGetQuestionsThrowingNoResults() async throws {
        mockOpenTDB.getQuestionsError = .noResults
        try await viewModel.getQuestions()
        let alert = try XCTUnwrap(viewModel.alert)
        XCTAssertEqual(alert.type, .noResults)
    }
    
    func testGetQuestionsThrowingSeenAllQuestions() async throws {
        mockOpenTDB.getQuestionsError = .seenAllQuestions
        try await viewModel.getQuestions()
        let alert = try XCTUnwrap(viewModel.alert)
        XCTAssertEqual(alert.type, .seenAllQuestions)
    }
    
    func testGetQuestionsThrowingServerStatus() async throws {
        mockOpenTDB.getQuestionsError = .serverStatus(code: 404)
        try await viewModel.getQuestions()
        let alert = try XCTUnwrap(viewModel.alert)
        XCTAssertEqual(alert.type, .serverStatus)
    }
    
    func testGetQuestionsThrowingOther() async throws {
        mockOpenTDB.getQuestionsError = .invalidParameter
        try await viewModel.getQuestions()
        let alert = try XCTUnwrap(viewModel.alert)
        XCTAssertEqual(alert.type, .other)
    }
    
    func testGetQuestionsThrowingUnknownError() async throws {
        mockOpenTDB.otherError = NSError(domain: "some domain", code: -1)
        try await viewModel.getQuestions()
        let alert = try XCTUnwrap(viewModel.alert)
        XCTAssertEqual(alert.type, .other)
    }
}
