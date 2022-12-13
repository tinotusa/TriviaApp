//
//  TriviaAPI.swift
//  TriviaApp
//
//  Created by Tino on 6/12/2022.
//

import Foundation
import os

/// API wrapper for [Opentdb](https://opentdb.com)
final class TriviaAPI {
    /// The current sessions token.
    var sessionToken: String?
    /// Settings for the trivia questions.
    var triviaConfig: TriviaConfig
    
    static var shared = TriviaAPI()
    
    /// Decoder for the wrapper.
    private let decoder: JSONDecoder
    /// Logger for the class
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "TriviaAPI")
    
    /// Creates a TriviaAPI.
    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        triviaConfig = .default
    }
}

extension TriviaAPI {
    /// A boolean value indicating whether or not there is a session.
    var hasSessionToken: Bool {
        sessionToken != nil
    }
    
    /// Gets questions from opentdb based on the config settings.
    /// - Returns: An array of questions.
    func getQuestions() async throws -> [TriviaQuestion] {
        log.debug("Getting questions using the config settings: \(self.triviaConfig)")
        
        if !hasSessionToken {
            log.debug("No session token. Requesting a new one.")
            self.sessionToken = try await requestToken()
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opentdb.com"
        components.path = "/api.php"
        components.queryItems = [
            .init(name: "amount", value: "\(triviaConfig.numberOfQuestions)"),
            .init(name: "category", value: triviaConfig.category.id != 0 ? "\(triviaConfig.category.id)" : nil),
            .init(name: "difficulty", value: triviaConfig.difficulty != .any ? triviaConfig.difficulty.rawValue : nil),
            .init(name: "type", value: triviaConfig.triviaType != .any ? triviaConfig.triviaType.rawValue : nil),
            .init(name: "token", value: sessionToken),
            .init(name: "encode", value: "url3986") // TODO: does this need to be changed?
        ]
        guard let url = components.url else {
            log.error("Failed to get questions. URL is invalid.")
            throw TriviaAPIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse,
           !(200 ..< 300).contains(response.statusCode)
        {
            log.error("Failed to get questions. Invalid server response: \(response.statusCode)")
            throw TriviaAPIError.serverError(code: response.statusCode)
        }
        
        let questionsResponse = try decoder.decode(QuestionsResponse.self, from: data)
        guard questionsResponse.responseCode == 0 else {
            guard let responseCode = ResponseCode(rawValue: questionsResponse.responseCode) else {
                log.error("Failed to get questions. Unknown response code: \(questionsResponse.responseCode)")
                throw TriviaAPIError.unknownError
            }
            log.error("Failed to get questions. Invalid api response code: \(questionsResponse.responseCode)")
            throw TriviaAPIError.responseError(code: responseCode)
        }
        
        log.debug("Successfully got \(questionsResponse.results.count) questions from the api.")
        return questionsResponse.results
    }
}

private extension TriviaAPI {
    /// Requests opentdb for a session token.
    ///
    /// This token is used to keep track of the questions that have already been asked.
    /// This token will also help indicate when the user has exhausted all questions and
    /// needs to the refreshed.
    ///
    /// - Returns: A session token.
    func requestToken() async throws -> String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opentdb.com"
        components.path = "/api_token.php"
        components.queryItems = [
            .init(name: "command", value: "request")
        ]
        
        guard let url = components.url else {
            throw TriviaAPIError.invalidURL
        }
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse,
           !(200 ..< 300).contains(response.statusCode)
        {
            throw TriviaAPIError.serverError(code: response.statusCode)
        }
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        if tokenResponse.responseCode != 0 {
            guard let responseCode = ResponseCode(rawValue: tokenResponse.responseCode) else {
                throw TriviaAPIError.unknownError
            }
            throw TriviaAPIError.responseError(code: responseCode)
        }
        
        return tokenResponse.token
    }
}
