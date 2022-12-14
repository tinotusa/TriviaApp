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
    let score: Int
    /// All the questions that were asked.
    let questions: [TriviaQuestion]
    /// The questions that were answered incorrectly.
    let wrongQuestions: [TriviaQuestion]
    
    /// The score as a percentage.
    var percentage: Int {
        questions.count / score
    }
}
