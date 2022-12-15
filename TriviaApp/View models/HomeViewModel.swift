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
    @Published var triviaConfig = TriviaAPI.TriviaConfig.default
    @Published private(set) var isLoading = false
    @Published private(set) var questions: [TriviaQuestion] = []
    @Published var showingAlert = false
    @Published private(set) var alert: HomeViewAlert? = nil {
        didSet {
            showingAlert = true
        }
    }
    
    private lazy var triviaAPI = TriviaAPI.shared
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "HomeViewModel")
}

struct HomeViewAlert {
    /// The error message of the alert
    let message: String
    /// The type of the alert
    let type: AlertType
    /// A unique id for the alert.
    let id = UUID()
    
    enum AlertType {
        case noResults
        case seenAllQuestions
        case serverStatus
        case other
    }
}

extension HomeViewModel {
    /// Gets the trivia questions based on the given settings.
    @MainActor
    func generateQuestions() async {
        log.debug("Generating questions.")
        isLoading = true
        defer { isLoading = false }
        triviaAPI.triviaConfig = triviaConfig
        do {
            questions = try await triviaAPI.getQuestions()
            log.debug("Successfully generated \(self.questions.count) questions.")
        } catch let error as TriviaAPI.TriviaAPIError {
            switch error {
            case .noResults:
                alert = .init(message: "No results found.", type: .noResults)
            case .seenAllQuestions:
                alert = .init(message: "Seen all questions for this cateogry.", type: .seenAllQuestions)
            case .serverStatus(let code):
                alert = .init(message: "Invalid server status: \(code)", type: .serverStatus)
            default:
                alert = .init(message: "Something went wrong", type: .other)
            }
        } catch {
            log.error("Failed to generate questions. \(error)")
        }
    }
    
    /// Tries to reset the api token.
    func resetToken() async {
        do {
            try await triviaAPI.resetToken()
        } catch {
            log.error("Failed to reset the token. \(error)")
        }
    }
    
    /// Removes all of the questions that are currently loaded.
    func clearQuestions() {
        self.questions = []
    }
}
