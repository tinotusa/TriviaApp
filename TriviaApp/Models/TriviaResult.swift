//
//  TriviaResult.swift
//  TriviaApp
//
//  Created by Tino on 14/12/2022.
//

import Foundation

/// Results of a particular trivia round.
struct TriviaResult {
    /// The amount of correctly answered questions
    var score: Int {
        didSet {
            score = clamp(score: score)
        }
    }
    /// All the questions that were asked.
    var questions: [TriviaQuestion]
    /// The questions that were answered incorrectly.
    var wrongQuestions: [TriviaQuestion] = []
    
    init(score: Int = 0, questions: [TriviaQuestion], wrongQuestions: [TriviaQuestion] = []) {
        self.score = score
        self.questions = questions
        self.wrongQuestions = wrongQuestions
        self.score = clamp(score: score)
    }
}

extension TriviaResult {
    /// The score as a percentage.
    var percentage: Double {
        if score == 0 { return 0 }
        return round(Double(score) / Double(questions.count) * 100) / 100.0
    }
    
    /// A boolean value indicating whether the trivia round had any wrong answers.
    var isPerfectScore: Bool {
        score == questions.count
    }
    
    /// Limits the given value between a min and max value.
    ///
    /// 0 if `score` < 0
    ///
    /// questions.score if `score` > questions.score
    ///
    /// The value unchanged.
    ///
    /// - Parameter score: The score to clamp.
    /// - Returns: The clamped value
    private func clamp(score: Int) -> Int {
        if score < 0 { return 0 }
        else if score > questions.count { return questions.count }
        return score
    }
}
