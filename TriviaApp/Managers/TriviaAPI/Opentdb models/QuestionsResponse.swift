//
//  QuestionsResponse.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

/// Model for opentdb's questions
struct QuestionsResponse: Codable {
    /// The response code.
    let responseCode: Int
    /// The questions and answers.
    let results: [TriviaQuestion]
}
