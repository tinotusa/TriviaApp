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
    
    private let _category: String
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
    
    /// The category of the question.
    var category: String {
        _category.removingPercentEncoding!
    }
    
    /// The question.
    var question: String {
        _question.removingPercentEncoding!
    }
    
    /// The correct answer.
    var correctAnswer: String {
        _correctAnswer.removingPercentEncoding!
    }
    
    /// The incorrect answers.
    var incorrectAnswers: [String] {
        _incorrectAnswers.compactMap { $0.removingPercentEncoding }
    }
    
    /// All the answers (correct and incorrect).
    var allAnswers: [String] {
        var answers = incorrectAnswers
        answers.append(correctAnswer)
        answers.shuffle()
        return answers
    }
}
