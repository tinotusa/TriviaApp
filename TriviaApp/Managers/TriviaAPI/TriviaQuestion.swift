//
//  TriviaQuestion.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

/// Model for the questions of the trivia.
struct TriviaQuestion: Codable, Hashable {
    /// The type of question.
    let type: String
    /// The difficulty of the question.
    let difficulty: String
    /// The category of the question.
    let category: String
    /// The question.
    let question: String
    /// The correct answer.
    let correctAnswer: String
    /// The incorrect answers.
    let incorrectAnswers: [String]
    
    /// All of the answers to the question
    let allAnswers: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try container.decode(String.self, forKey: .category).removingPercentEncoding!
        self.type = try container.decode(String.self, forKey: .type)
        self.difficulty = try container.decode(String.self, forKey: .difficulty)
        self.question = try container.decode(String.self, forKey: .question).removingPercentEncoding!
        self.correctAnswer = try container.decode(String.self, forKey: .correctAnswer).removingPercentEncoding!
        self.incorrectAnswers = try container.decode([String].self, forKey: .incorrectAnswers).compactMap { $0.removingPercentEncoding! }
        
        var allAnswers = incorrectAnswers
        allAnswers.append(correctAnswer)
        allAnswers.shuffle()
        
        self.allAnswers = allAnswers
    }
}
