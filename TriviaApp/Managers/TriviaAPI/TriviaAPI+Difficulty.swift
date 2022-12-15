//
//  TriviaAPI+Difficulty.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import SwiftUI

extension TriviaAPI {
    /// Difficulty options for the trivia.
    enum TriviaDifficulty: String, CaseIterable, Identifiable {
        case any
        case easy
        case medium
        case hard
        
        /// A unique id.
        var id: Self { self }
        
        /// The title of the case.
        var title: LocalizedStringKey {
            switch self {
            case .any: return LocalizedStringKey("Any")
            case .easy: return LocalizedStringKey("Easy")
            case .hard: return LocalizedStringKey("Hard")
            case .medium: return LocalizedStringKey("Medium")
            }
        }
    }
}
