//
//  QuestionsResponse.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation

struct QuestionsResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]
}
