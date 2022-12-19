//
//  QuestionsViewModel.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import Foundation
import os
import SwiftUI

/// View model for the QuestionsView.
final class QuestionsViewModel: ObservableObject {
    /// The loading state of the view.
    @Published private(set) var viewLoadingState = ViewLoadingState.loading
    /// The current question's index.
    @Published private(set) var currentQuestionIndex = 0
    /// A boolean value indicating whether the trivia quiz is over.
    @Published private(set) var isQuizOver = false
    /// The questions of the trivia quiz.
    @Published private(set) var questions: [TriviaQuestion] = []
    /// The results of the trivia round.
    @Published private(set) var quizResult: TriviaResult = .init(questions: [])
    /// The currently selected answer.
    @Published var selectedAnswer: String? = nil
    /// The answers that are currently hidden.
    @Published var hiddenAnswers = [String]()
    /// The config for the trivia.
    private let triviaConfig: TriviaAPI.TriviaConfig
    /// Answers to hide when hint is pressed.
    private var answersLeftToHide: [String]?
    /// The trivia api.
    private var triviaAPI = TriviaAPI.shared
    
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
    init(triviaConfig: TriviaAPI.TriviaConfig) {
        self.triviaConfig = triviaConfig
    }
}

extension QuestionsViewModel {
    /// Alert details of the view.
    struct Alert {
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
}

extension QuestionsViewModel {
    /// The current question.
    @MainActor
    var currentQuestion: TriviaQuestion? {
        guard currentQuestionIndex < questions.count else {
            isQuizOver = true
            log.debug("Current question index is out of bounds. index: \(self.currentQuestionIndex)")
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
    /// - Returns: True if the submitted answer was correct, false otherwise.
    @MainActor
    func submitAnswer() -> Bool {
        log.debug("Submitting answer.")
        guard let selectedAnswer else {
            log.error("Error tried to submit a nil answer")
            return false
        }
        let isCorrect = checkAnswer(answer: selectedAnswer)
        nextQuestion()
        self.selectedAnswer = nil
        clearHiddenAnswers()
        clearIncorrectAnswers()
        log.debug("Successfully submitted an answer")
        return isCorrect
    }
    
    /// Hides one of the incorrect answers
    @MainActor
    func showHint() {
        log.debug("Showing a hint")
        guard let answersLeftToHide, !answersLeftToHide.isEmpty else {
            log.debug("Cannot have more hints.")
            return
        }
        guard let question = currentQuestion else {
            log.error("Error. No current question.")
            return
        }
        if question.type == "boolean" {
            log.debug("Cannot show hint for a boolean question.")
            return
        }
        if let answerToHide = self.answersLeftToHide?.removeFirst() {
            hiddenAnswers.append(answerToHide)
            if answerToHide == selectedAnswer {
                selectedAnswer = nil
            }
            log.debug("Hidden the incorrect answer: \(answerToHide)")
        } else {
            log.error("There are no answers to hide.")
        }
    }
    
    /// Returns true if the given answer is hidden.
    /// - Parameter answer: The answer to check.
    /// - Returns: True if the answer is hidden, false otherwise.
    func isAnswerHidden(answer: String) -> Bool {
        hiddenAnswers.contains(answer)
    }
    
    /// Sets the current incorrect answers to nil.
    ///
    ///  This is called after a question is submitted, so that the next
    ///  question can set its own incorrect answers.
    @MainActor
    func clearIncorrectAnswers() {
        log.debug("Clearing the shuffled incorrect answers.")
        answersLeftToHide = nil
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
    /// Fetches some questions of opentdb based on the given trivia config.
    @MainActor
    func getQuestions() async {
        log.debug("Getting questions based on config \(self.triviaConfig)")
        do {
            triviaAPI.triviaConfig = triviaConfig
            self.questions = try await triviaAPI.getQuestions()
            quizResult.questions = self.questions
            viewLoadingState = .loaded
            log.debug("Successfully loaded \(self.questions.count) questions.")
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
            viewLoadingState = .error(error: error)
            log.error("TriviaAPI Error. Failed to get questions. \(error)")
        } catch {
            viewLoadingState = .error(error: error)
            log.error("Failed to get questions. \(error)")
        }
    }
    
    /// Tries to reset the api token.
    ///
    ///  This will also reset the view's loading state to loading.
    @MainActor
    func resetQuestions() async {
        do {
            try await triviaAPI.resetToken()
            viewLoadingState = .loading
        } catch {
            log.error("Failed to reset the token. \(error)")
        }
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
        guard currentQuestionIndex < questions.count else {
            isQuizOver = true
            log.debug("Tried to check answer when question index was out of bounds. index: \(self.currentQuestionIndex)")
            return false
        }
        
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = currentQuestion.correctAnswer == answer
        if isCorrect {
            log.debug("The answer was correct.")
            quizResult.score += 1
            return true
        }
        log.debug("The answer was incorrect.")
        quizResult.wrongQuestions.append(currentQuestion)
        return false
    }
    
    /// Updates to the next question.
    @MainActor
    func nextQuestion() {
        log.debug("Updating to next question.")
        guard currentQuestionIndex < questions.count - 1 else {
            withAnimation {
                isQuizOver = true
            }
            log.debug("Reached end of questions. Quiz is over.")
            return
        }
        currentQuestionIndex += 1
        log.debug("Current question index is: \(self.currentQuestionIndex)")
    }
    
    
    /// Resets the hidden answers for the next question.
    @MainActor
    func clearHiddenAnswers() {
        log.debug("Clearing the hidden answers.")
        hiddenAnswers = []
    }
}
