//
//  TriviaResultTests.swift
//  TriviaAppTests
//
//  Created by Tino on 22/12/2022.
//

import XCTest
@testable import TriviaApp

final class TriviaResultTests: XCTestCase {
    var questions: Set<Question>!
    
    override func setUpWithError() throws {
        questions = Set(Bundle.main.loadJSON(QuestionsResponse.self, filename: "exampleQuestions").results)
    }
    
    func testDefaultInit() throws {
        let result = TriviaResult(questions: questions)
        XCTAssertEqual(result.score, 0, "Expected trivia results score to be 0")
        XCTAssertEqual(result.percentage, 0, "Expected trivia results percentage to be 0")
    }
    
    func testPercentage() throws {
        let score = Int.random(in: 0 ..< questions.count)
        let expectedPercentage = Double(score) / Double(questions.count)
        let result = TriviaResult(score: score, questions: questions)
        let percentage = result.percentage
        XCTAssertEqual(percentage, expectedPercentage, "Expected trivia results percentage to be \(expectedPercentage), not \(percentage)")
    }
    
    func testScore() throws {
        let result = TriviaResult(score: questions.count, questions: questions)
        XCTAssertTrue(result.isPerfectScore, "Expected the result to have a perfect score.")
    }
    
    func testInvalidScore() throws {
        let result = TriviaResult(score: -1, questions: questions)
        let result2 = TriviaResult(score: 100, questions: questions)
        XCTAssertEqual(result.score, 0, "Expected the result to have a score of 0.")
        XCTAssertEqual(result2.score, questions.count, "Expected the result to have a score of \(questions.count).")
    }
}
