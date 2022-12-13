//
//  TriviaAPI.swift
//  TriviaApp
//
//  Created by Tino on 6/12/2022.
//

import Foundation
import os

final class TriviaAPI {
    var sessionToken: String?
    var triviaConfig: TriviaConfig
    
    static var shared = TriviaAPI()
    
    private let apiURL = URL(string: "https://opentdb.com")!
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.tinotusa.TriviaApp", category: "TriviaAPI")
    
    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        triviaConfig = .default
    }
}

extension TriviaAPI {
    var hasSessionToken: Bool {
        sessionToken != nil
    }

    func getQuestions() async throws -> [TriviaQuestion] {
        logger.debug("Getting questions using the config settings: \(self.triviaConfig)")
        
        if !hasSessionToken {
            logger.debug("No session token. Requesting a new one.")
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
            logger.error("Failed to get questions. URL is invalid.")
            throw TriviaAPIError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse,
           !(200 ..< 300).contains(response.statusCode)
        {
            logger.error("Failed to get questions. Invalid server response: \(response.statusCode)")
            throw TriviaAPIError.serverError(code: response.statusCode)
        }
        
        let questionsResponse = try decoder.decode(QuestionsResponse.self, from: data)
        guard questionsResponse.responseCode == 0 else {
            guard let responseCode = ResponseCode(rawValue: questionsResponse.responseCode) else {
                logger.error("Failed to get questions. Unknown response code: \(questionsResponse.responseCode)")
                throw TriviaAPIError.unknownError
            }
            logger.error("Failed to get questions. Invalid api response code: \(questionsResponse.responseCode)")
            throw TriviaAPIError.responseError(code: responseCode)
        }
        
        logger.debug("Successfully got \(questionsResponse.results.count) questions from the api.")
        return questionsResponse.results
    }
}

private extension TriviaAPI {
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
