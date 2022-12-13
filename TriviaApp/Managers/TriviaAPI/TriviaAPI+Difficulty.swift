//
//  TriviaAPI+Difficulty.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
extension TriviaAPI {
    enum TriviaDifficulty: String, CaseIterable, Identifiable {
        case any
        case easy
        case medium
        case hard
        
        var id: Self { self }
    }
    
}
