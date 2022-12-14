//
//  TriviaAPI+TriviaType.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
extension TriviaAPI {
    /// The question types for the trivia.
    enum TriviaType: String, CaseIterable, Identifiable {
        case any
        case multipleChoice = "multiple"
        case trueOrFalse = "boolean"
        
        /// A unique id.
        var id: Self { self }
        
        /// The title of the type.
        var title: String {
            switch self {
            case .any: return "Any"
            case .multipleChoice: return "Multiple choice"
            case .trueOrFalse: return "True or false"
            }
        }
    }
}
