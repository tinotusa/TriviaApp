//
//  MockTriviaAPI.swift
//  TriviaAppTests
//
//  Created by Tino on 19/12/2022.
//

import Foundation
@testable import TriviaApp

/// Mock TriviaAPI used for testing.
final class MockTriviaAPI: TriviaAPIProtocol {
    var triviaConfig: TriviaConfig
    var getQuestionsError: TriviaAPI.TriviaAPIError?
    var otherError: Error?
    var resetTokenError: TriviaAPI.TriviaAPIError?
    
    init(triviaConfig: TriviaConfig) {
        self.triviaConfig = triviaConfig
    }
    
    func getQuestions() async throws -> [Question] {
        if let getQuestionsError {
            throw getQuestionsError
        }
        if let otherError {
            throw otherError
        }
        return Bundle.main.loadJSON(QuestionsResponse.self, filename: "exampleQuestions").results
    }
    
    func resetToken() async throws {
        if let resetTokenError {
            throw resetTokenError
        }
    }
}
