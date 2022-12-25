//
//  MockTriviaAPI.swift
//  TriviaAppTests
//
//  Created by Tino on 19/12/2022.
//

import Foundation
import SwiftOpenTDB
@testable import TriviaApp

/// Mock TriviaAPI used for testing.
final class MockOpenTDB: OpenTDBProtocol {
    var sessionToken: String?
    
    func requestToken() async throws {
        
    }
    
    var triviaConfig: TriviaConfig
    var getQuestionsResponseError: TriviaAPIResponseError?
    var getQuestionsServerError: OpenTDBError?
    var otherError: Error?
    var resetTokenError: OpenTDBError?
    
    init(triviaConfig: TriviaConfig) {
        self.triviaConfig = triviaConfig
    }
    
    func getQuestions() async throws -> [Question] {
        if let getQuestionsResponseError {
            throw getQuestionsResponseError
        } else if let getQuestionsServerError {
            throw getQuestionsServerError
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
