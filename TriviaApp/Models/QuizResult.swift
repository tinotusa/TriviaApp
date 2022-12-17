//
//  QuizResult.swift
//  TriviaApp
//
//  Created by Tino on 14/12/2022.
//

import Foundation

/// Results of a particular quiz round.
struct QuizResult {
    /// The amount of correctly answered questions
    var score: Int = 0
    /// All the questions that were asked.
    var questions: [TriviaQuestion]
    /// The questions that were answered incorrectly.
    var wrongQuestions: [TriviaQuestion] = []
    
    /// The score as a percentage.
    var percentage: Double {
        if score == 0 { return 0 }
        return Double(score) / Double(questions.count)
    }
}
