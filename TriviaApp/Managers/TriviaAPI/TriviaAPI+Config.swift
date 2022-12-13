//
//  TriviaAPI+Config.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

extension TriviaAPI {
    /// Settings for the trivia.
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
