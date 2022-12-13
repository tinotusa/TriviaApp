//
//  HomeViewModel.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import os

final class HomeViewModel: ObservableObject {
    @Published var numberOfQuestions = 10
    @Published var category: TriviaAPI.TriviaCategory = .anyCategory
    @Published var difficulty: TriviaAPI.TriviaDifficulty = .any
    @Published var triviaType: TriviaAPI.TriviaType = .any

    @Published private(set) var questions: [TriviaQuestion] = []
    
    private lazy var triviaAPI = TriviaAPI.shared
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "HomeViewModel")
}

extension HomeViewModel {
    func generateQuestions() async {
        triviaAPI.triviaConfig = .init(numberOfQuestions: numberOfQuestions, category: category, difficulty: difficulty, triviaType: triviaType)
        do {
            questions = try await triviaAPI.getQuestions()
        } catch {
            log.error("Failed to generate questions. \(error)")
        }
    }
}
