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
    
    enum TriviaAPIError: Error {
        case invalidURL
        case serverError(code: Int)
        case responseError(code: ResponseCode)
        case unknownError
    }
    
    /// Responses from the opentdb api.
    enum ResponseCode: Int {
        /// Returned results successfully.
        case success
        /// Could not return results. The API doesn't have enough questions for your query.
        case noResults
        /// Parameter Contains an invalid parameter. Arguments passed in aren't valid.
        case invalidParameter
        /// Session Token does not exist.
        case tokenNotFound
        /// Session Token has returned all possible questions for the specified query. Resetting the Token is necessary.
        case tokenEmpty
    }
    
    // TODO: Move me.
    enum TriviaCategory: CaseIterable, Identifiable, Hashable {
        static var allCases: [TriviaAPI.TriviaCategory] = [
            .anyCategory, .generalKnowledge, .mythology, .sports, .geography, .history, .politics,
            .art, .celebrities, .animals, .vehicles
        ]
        + TriviaCategory.Entertainment.allCases.map { TriviaCategory.entertainment($0) }
        + TriviaCategory.Science.allCases.map { TriviaCategory.science($0) }
        
        enum Entertainment: CaseIterable, Identifiable, Hashable {
            case books
            case film
            case music
            case musicalsAndTheatres
            case television
            case videoGames
            case boardGames
            case comics
            case japaneseAnimeAndManga
            case cartoonAndAnimations
            
            var id: Int {
                switch self {
                case .books:
                    return 10
                case .film:
                    return 11
                case .music:
                    return 12
                case .musicalsAndTheatres:
                    return 13
                case .television:
                    return 14
                case .videoGames:
                    return 15
                case .boardGames:
                    return 16
                case .comics:
                    return 29
                case .japaneseAnimeAndManga:
                    return 31
                case .cartoonAndAnimations:
                    return 32
                }
            }
            
            var title: String {
                switch self {
                case .books: return "Books"
                case .film: return "Film"
                case .music: return "Music"
                case .musicalsAndTheatres: return "Musicals and Theatres"
                case .television: return "Television"
                case .videoGames: return "Video games"
                case .boardGames: return "Boardgames"
                case .comics: return "Comics"
                case .japaneseAnimeAndManga: return "Japanese Anime and Manga"
                case .cartoonAndAnimations: return "Cartoon and Animations"
                }
            }
        }
        
        enum Science: CaseIterable, Identifiable, Hashable {
            case scienceAndNature
            case computers
            case mathematics
            case gadgets
            
            var id: Int {
                switch self {
                case .scienceAndNature:
                    return 17
                case .computers:
                    return 18
                case .mathematics:
                    return 19
                case .gadgets:
                    return 30
                }
            }
            
            var title: String {
                switch self {
                case .scienceAndNature: return "Science and Nature"
                case .computers: return "Computers"
                case .mathematics: return "Mathematics"
                case .gadgets: return "Gadgets"
                }
            }
        }
        
        case anyCategory
        case generalKnowledge
        case mythology
        case sports
        case geography
        case history
        case politics
        case art
        case celebrities
        case animals
        case vehicles
        case entertainment(Entertainment)
        case science(Science)
        
        var id: Int {
            switch self {
            case .anyCategory:
                return 0
            case .generalKnowledge:
                return 9
            case .mythology:
                return 20
            case .sports:
                return 21
            case .geography:
                return 22
            case .history:
                return 23
            case .politics:
                return 24
            case .art:
                return 25
            case .celebrities:
                return 26
            case .animals:
                return 27
            case .vehicles:
                return 28
            case .entertainment(let entertainment):
                return entertainment.id
            case .science(let science):
                return science.id
            }
        }
        
        var title: String {
            switch self {
            case .anyCategory: return "Any Category"
            case .generalKnowledge: return "General Knowledge"
            case .mythology: return "Mythology"
            case .sports: return "Sports"
            case .geography: return "Geography"
            case .history: return "History"
            case .politics: return "Politics"
            case .art: return "Art"
            case .celebrities: return "Celebrities"
            case .animals: return "Animals"
            case .vehicles: return "Vehicles"
            case .entertainment(let entertainment): return entertainment.title
            case .science(let science): return science.title
            }
        }
    }
    
    enum TriviaDifficulty: String, CaseIterable, Identifiable {
        case any
        case easy
        case medium
        case hard
        
        var id: Self { self }
    }
    
    enum TriviaType: String {
        case any
        case multipleChoice = "multiple"
        case trueOrFalse = "boolean"
    }
    
    struct TriviaConfig: CustomStringConvertible {
        let numberOfQuestions: Int
        let category: TriviaCategory
        let difficulty: TriviaDifficulty
        let triviaType: TriviaType
        /// The max number of questions allowed by the api.
        private static var maxQuestions = 50
        
        /// Creates the settings for the trivia api
        /// - Parameters:
        ///   - numberOfQuestions: The number of questions to ask (max of 50).
        ///   - category: The category of the questions.
        ///   - difficulty: The difficulty of the questions.
        ///   - triviaType: The type of the trivia questions (multiple, true or false).
        init(numberOfQuestions: Int, category: TriviaCategory, difficulty: TriviaDifficulty, triviaType: TriviaType) {
            self.numberOfQuestions = min(max(0, numberOfQuestions), Self.maxQuestions)
            self.category = category
            self.difficulty = difficulty
            self.triviaType = triviaType
        }
        
        /// The default settings for the trivia.
        static var `default`: TriviaConfig {
            TriviaConfig(numberOfQuestions: 10, category: .anyCategory, difficulty: .easy, triviaType: .any)
        }
        
        var description: String {
            """
            config settings:
            number of questions: \(numberOfQuestions)
            category: \(category.id != 0 ? "\(category.id)" : "any category")
            difficulty: \(difficulty.rawValue)
            trivia type: \(triviaType.rawValue)
            """
        }
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

struct TokenResponse: Codable {
    let responseCode: Int
    let responseMessage: String
    let token: String
}

struct QuestionsResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Hashable {
    private let _category: String
    let type: String
    let difficulty: String
    private let _question: String
    private let _correctAnswer: String
    private let _incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case _category = "category"
        case type
        case difficulty
        case _question = "question"
        case _correctAnswer = "correctAnswer"
        case _incorrectAnswers = "incorrectAnswers"
    }
    
    var category: String {
        _category.removingPercentEncoding!
    }
    
    var question: String {
        _question.removingPercentEncoding!
    }
    
    var correctAnswer: String {
        _correctAnswer.removingPercentEncoding!
    }
    
    var incorrectAnswers: [String] {
        _incorrectAnswers.compactMap { $0.removingPercentEncoding }
    }
}
