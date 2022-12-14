//
//  HomeViewModel.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import os

/// View model for HomeView.
final class HomeViewModel: ObservableObject {
    @Published var numberOfQuestions = 10
    @Published var category: TriviaAPI.TriviaCategory = .anyCategory
    @Published var difficulty: TriviaAPI.TriviaDifficulty = .any
    @Published var triviaType: TriviaAPI.TriviaType = .any
    @Published private(set) var isLoading = false
    @Published private(set) var questions: [TriviaQuestion] = []
    
    @Published var showSeenAllAlert = false
    
    private lazy var triviaAPI = TriviaAPI.shared
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "HomeViewModel")
}

extension HomeViewModel {
    /// Gets the trivia questions based on the given settings.
    @MainActor
    func generateQuestions() async {
        log.debug("Generating questions.")
        isLoading = true
        defer { isLoading = false }
        triviaAPI.triviaConfig = .init(numberOfQuestions: numberOfQuestions, category: category, difficulty: difficulty, triviaType: triviaType)
        do {
            questions = try await triviaAPI.getQuestions()
            log.debug("Successfully generated \(self.questions.count) questions.")
        } catch TriviaAPI.TriviaAPIError.seenAllQuestions {
            showSeenAllAlert = true
        } catch {
            log.error("Failed to generate questions. \(error)")
        }
    }
    
    /// Tries to reset the api token.
    func resetToken() async {
        do {
            triviaAPI.sessionToken = try await triviaAPI.resetToken()
        } catch {
            log.error("Failed to reset the token. \(error)")
        }
    }
}
