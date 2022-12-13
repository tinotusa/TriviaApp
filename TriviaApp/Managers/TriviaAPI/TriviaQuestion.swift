//
//  TriviaQuestion.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

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
