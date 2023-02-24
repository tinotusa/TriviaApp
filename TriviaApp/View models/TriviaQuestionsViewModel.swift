//
//  QuestionsViewModel.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import os
import SwiftUI
import SwiftOpenTDB

protocol OpenTDBProtocol {
    var sessionToken: String? { get set }
    var triviaConfig: TriviaConfig { get set }
    func getQuestions() async throws -> [Question]
    func resetToken() async throws
    func requestToken() async throws
}

extension OpenTDB: OpenTDBProtocol {
    
}

/// View model for the QuestionsView.
final class QuestionsViewModel: ObservableObject {
    /// The loading state of the view.
    @Published var viewLoadingState = ViewLoadingState.loading
    /// The current question's index.
    @Published private(set) var currentQuestionIndex = 0
    /// A boolean value indicating whether the trivia round is over.
    @Published private(set) var isTriviaRoundOver = false
    /// The questions of the trivia round.
    @Published var questions: [Question] = []
    /// The results of the trivia round.
    @Published var triviaResult: TriviaResult = .init(questions: [])
    /// The currently selected answer.
    @Published var selectedAnswer: String? = nil
    /// The answers that are currently hidden.
    @Published var hiddenAnswers = [String]()
    /// The config for the trivia.
    private let triviaConfig: TriviaConfig
    /// Answers to hide when hint is pressed.
    private var answersLeftToHide: [String]?
    /// The trivia api.
    private var openTDB: OpenTDBProtocol
    
    /// A boolean value indicating whether an alert is being shown.
    @Published var showingAlert = false
    /// The alert details used when alert is shown.
    @Published private(set) var alert: Alert? = nil {
        didSet {
            showingAlert = true
            print("showing alert is now \(showingAlert)")
        }
    }
    
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "QuestionsViewModel")
    
    /// Creates the view model.
    /// - Parameter triviaConfig: The config for the trivia.
    init(triviaConfig: TriviaConfig, openTDB: OpenTDBProtocol = OpenTDB.shared) {
        self.triviaConfig = triviaConfig
        self.openTDB = openTDB
    }
}

extension QuestionsViewModel {
    /// Alert details of the view.
    struct Alert {
        /// The error message of the alert
        let message: String
        /// The type of the alert
        let type: AlertType
        
        enum AlertType {
            case noResults
            case seenAllQuestions
            case serverStatus
            case emptyToken
            case other
        }
    }
}

extension QuestionsViewModel {
    /// The current question.
    @MainActor
    var currentQuestion: Question? {
        if !isValidQuestionIndex {
            isTriviaRoundOver = true
            return nil
        }
        let question = questions[currentQuestionIndex]
        if answersLeftToHide == nil {
            // This is so that its set once.
            // This will be set to nil after submitAnswer is called.
            answersLeftToHide = question.incorrectAnswers.shuffled()
        }
        return question
    }
    
    /// A boolean value indicating whether or not an answer has been selected.
    var hasSelectedAnswer: Bool {
        selectedAnswer != nil
    }
    
    /// Checks the current answer and moves on to the next question.
    /// - Returns: `true` if the submitted answer was correct; `false` otherwise.
    @MainActor
    func submitAnswer() -> Bool {
        log.debug("Submitting answer.")
        guard let selectedAnswer else {
            log.error("Error tried to submit a nil answer")
            return false
        }
        let isCorrect = checkAnswer(answer: selectedAnswer)
        nextQuestion()
        resetQuestionState()
        log.debug("Successfully submitted an answer")
        return isCorrect
    }
    
    /// Hides one of the incorrect answers
    /// - Returns: `true` if a hint was shown; `false` otherwise.
    @MainActor
    func showHint() -> Bool {
        log.debug("Showing a hint")
        guard let question = currentQuestion else {
            log.error("Error. No current question.")
            return false
        }
        if question.type == "boolean" {
            log.debug("Cannot show hint for a boolean question.")
            return false
        }
        if let answersLeftToHide, !answersLeftToHide.isEmpty {
            let answerToHide = self.answersLeftToHide!.removeFirst()
            hiddenAnswers.append(answerToHide)
            if answerToHide == selectedAnswer {
                selectedAnswer = nil
            }
            log.debug("Hidden the incorrect answer: \(answerToHide)")
            return true
        }
        log.debug("Cannot have more hints.")
        return false
    }
    
    /// Returns true if the given answer is hidden.
    /// - Parameter answer: The answer to check.
    /// - Returns: True if the answer is hidden, false otherwise.
    func isAnswerHidden(answer: String) -> Bool {
        hiddenAnswers.contains(answer)
    }
    
    
    /// Resets the state of the question to default
    ///
    /// The hints have been reset back to 0 for the new question.
    @MainActor
    func resetQuestionState() {
        log.debug("Clearing the shuffled incorrect answers, and hidden answers.")
        selectedAnswer = nil
        answersLeftToHide = nil
        hiddenAnswers = []
    }
    
    /// Returns true if there are already three hidden answers
    var hintsDisabled: Bool {
        if let answersLeftToHide, answersLeftToHide.isEmpty {
            return true
        }
        return false
    }
}

// MARK: - Trivia api functions
extension QuestionsViewModel {
    @MainActor
    func loadData() async {
        log.debug("Loading data.")
        if openTDB.sessionToken == nil {
            do {
                try await openTDB.requestToken()
                log.debug("Successfully requested a token.")
            } catch {
                viewLoadingState = .error(error: error)
                log.error("Failed to load data. \(error)")
            }
        }
        do {
            try await getQuestions()
            viewLoadingState = .loaded
            log.debug("Successfully loaded data.")
        } catch {
            viewLoadingState = .error(error: error)
            log.error("Failed to get questions. \(error)")
        }
    }
    
    /// Fetches some questions of opentdb based on the given trivia config.
    @MainActor
    func getQuestions() async throws {
        log.debug("Getting questions based on config \(self.triviaConfig)")
        do {
            openTDB.triviaConfig = triviaConfig
            self.questions = try await openTDB.getQuestions()
            triviaResult.questions = Set(self.questions)
            log.debug("Successfully got \(self.questions.count) questions.")
        } catch let error as TriviaAPIResponseError {
            switch error {
            case .noResults:
                alert = .init(message: "No results found.", type: .noResults)
                log.error("Failed to get questions. no results found.")
            case .tokenNotFound:
                log.debug("Failed to get questions. no session token. Will request a token.")
                try await requestNewToken()
                try await getQuestions()
            case .emptyToken:
                alert  = .init(message: "Cannot load anymore questions in this category. You have seen all of them", type: .emptyToken)
                log.debug("Failed to get questions. The session token is empty. It needs to be reset.")
            default:
                log.error("TriviaAPI Error. Unknown error: \(error)")
                alert = .init(message: "Unknown error", type: .other)
            }
        } catch {
            log.error("Failed to get questions. \(error)")
            alert = .init(message: error.localizedDescription, type: .other)
        }
    }
    
    /// Tries to request for a new token.
    func requestNewToken() async throws {
        log.debug("Requesting new token token.")
        try await openTDB.requestToken()
        UserDefaults.standard.setValue(openTDB.sessionToken, forKey: "sessionToken")
        log.debug("Successfully got token. new token: \(self.openTDB.sessionToken ?? "Nil token")")
    }
    
    /// Tries to reset the api token.
    ///
    ///  This will also reset the view's loading state to loading.
    /// - Returns: `true` if the questions where reset; `false` otherwise.
    @MainActor
    func resetQuestions() async -> Bool {
        do {
            try await openTDB.resetToken()
            UserDefaults.standard.setValue(openTDB.sessionToken, forKey: "sessionToken")
            viewLoadingState = .loading
            alert = nil
            return true
        } catch {
            log.error("Failed to reset the token. \(error)")
            return false
        }
    }
    
    /// Updates to the next question.
    @MainActor
    func nextQuestion() {
        log.debug("Updating to next question.")
        guard currentQuestionIndex < questions.count - 1 else {
            withAnimation {
                isTriviaRoundOver = true
            }
            log.debug("Reached end of questions. Trivia is over.")
            return
        }
        currentQuestionIndex += 1
        log.debug("Current question index is: \(self.currentQuestionIndex)")
    }
}

// MARK: - Private
private extension QuestionsViewModel {
    /// Checks the answer with the current question.
    /// - Parameter answer: The answer to check with.
    /// - Returns: True if the answer is correct, false otherwise.
    @MainActor
    func checkAnswer(answer: String) -> Bool {
        log.debug("Checking the answer.")
        
        guard let currentQuestion = currentQuestion else {
            log.error("No current question.")
            return false
        }
        
        let isCorrect = currentQuestion.correctAnswer == answer
        if isCorrect {
            log.debug("The answer was correct.")
            triviaResult.score += 1
            return true
        }
        log.debug("The answer was incorrect.")
        triviaResult.wrongQuestions.insert(currentQuestion)
        return false
    }
    
    /// Checks that the current index is valid.
    ///
    /// An index is valid if it is between 0 ..< questions.count
    /// - Returns: `true` if the index is value; `false` otherwise.
    var isValidQuestionIndex: Bool {
        let isValid = currentQuestionIndex < questions.count
        if !isValid {
            log.error("Error: Index \(self.currentQuestionIndex) is not valid. should be in range of 0 ..< \(self.questions.count).")
            return false
        }
        return true
    }
}
