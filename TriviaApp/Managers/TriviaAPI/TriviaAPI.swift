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
            throw TriviaAPIError.invalidAPIResponse(code: responseCode)
        }
        
        if let responseCode = ResponseCode(rawValue: questionsResponse.responseCode), responseCode == .tokenEmpty {
            log.debug("The token is empty. Will try to reset the token.")
            self.sessionToken = try await resetToken()
            log.debug("Successfully reset the token.")
            return try await getQuestions()
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
        log.debug("Requesting token.")
        let url = createOpenTriviaDatabaseURL(
            path: "/api_token.php",
            queryItems: [.init(name: "command", value: "request")]
        )
        
        guard let url else {
            log.error("Failed to request token. URL is invalid.")
            throw TriviaAPIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse,
           !isSuccessfulStatusCode(response)
        {
            log.error("Invalid server status code: \(response.statusCode)")
            throw TriviaAPIError.serverError(code: response.statusCode)
        }
        
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        if let responseCode = ResponseCode(rawValue: tokenResponse.responseCode),
            responseCode != .success
        {
            log.error("Invalid api response code: \(responseCode)")
            throw TriviaAPIError.invalidAPIResponse(code: responseCode)
        }
        
        log.debug("The token is: \(tokenResponse.token)")
        return tokenResponse.token
    }
    
    /// Creates a url for opentdb with the given path and query items.
    /// - Parameters:
    ///   - path: The path for the api.
    ///   - queryItems: The query items for the api.
    /// - Returns: A url if the path is valid, nil otherwise.
    func createOpenTriviaDatabaseURL(path: String, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "opentdb.com"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
    
    /// Resets the token and returns a new one.
    /// - Returns: A new session token.
    func resetToken() async throws -> String {
        if sessionToken == nil {
            log.error("Failed to reset the token. The token is nil.")
            throw TriviaAPIError.noSessonToken
        }
        
        log.debug("Reseting the token")
        let url = createOpenTriviaDatabaseURL(
            path: "/api_token.php",
            queryItems: [
                .init(name: "command", value: "reset"),
                .init(name: "token", value: self.sessionToken)
            ]
        )
        guard let url else {
            log.error("Failed to reset token. Invalid url.")
            throw TriviaAPIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            log.error("Failed to cast url response and http url response.")
            throw TriviaAPIError.unknownError
        }
        if !isSuccessfulStatusCode(httpResponse) {
            log.error("Invalid server response status code: \(httpResponse.statusCode)")
            throw TriviaAPIError.serverError(code: httpResponse.statusCode)
        }
        
        let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
        if !isValidAPIResponse(tokenResponse.responseCode) {
            log.error("Failed to reset token. Got invalid server response code: \(tokenResponse.responseCode)")
            throw TriviaAPIError.invalidAPIResponse(code: ResponseCode(rawValue: tokenResponse.responseCode)!)
        }
        
        log.debug("Successfully reset token.")
        return tokenResponse.token
    }
    
    /// Returns whether or not the given code is valid.
    ///
    /// A valid code is 0.
    ///
    /// Everything else is not valid.
    ///
    /// - Parameter code: The code from the server
    /// - Returns: True if the code is valid, false otherwise.
    func isValidAPIResponse(_ code: Int) -> Bool {
        code == 0
    }
    
    /// Returns whether or not the given response has a successful status code.
    /// - Parameter response: The response to check.
    /// - Returns: True if the response's status code is valid, false otherwise.
    func isSuccessfulStatusCode(_ response: HTTPURLResponse) -> Bool {
        (200 ..< 300).contains(response.statusCode)
    }
}
