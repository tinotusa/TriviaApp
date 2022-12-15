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
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var isQuizOver = false
    @Published private(set) var questions: [TriviaQuestion]
    @Published private(set) var wrongQuestions = [TriviaQuestion]()
    @Published private(set) var score = 0
    @Published var selectedAnswer: String? = nil
    
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "QuestionsViewModel")
    
    /// Creates the QuestionViewModel.
    init(questions: [TriviaQuestion]) {
        self.questions = questions
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
        return questions[currentQuestionIndex]
    }
    
    /// A boolean value indicating whether or not an answer has been selected.
    var hasSelectedAnswer: Bool {
        selectedAnswer != nil
    }
    
    /// Checks the current answer and moves on to the next question.
    @MainActor
    func submitAnswer() {
        log.debug("Submitting answer.")
        guard let selectedAnswer else {
            log.error("Error tried to submit a nil answer")
            return
        }
        checkAnswer(answer: selectedAnswer)
        nextQuestion()
        self.selectedAnswer = nil
        log.debug("Successfully submitted an answer")
    }
}

private extension QuestionsViewModel {
    /// Checks the answer with the current question.
    /// - Parameter answer: The answer to check with.
    /// - Returns: True if the answer is correct, false otherwise.
    @MainActor
    func checkAnswer(answer: String) {
        log.debug("Checking the answer.")
        guard currentQuestionIndex < questions.count else {
            isQuizOver = true
            log.debug("Tried to check answer when question index was out of bounds. index: \(self.currentQuestionIndex)")
            return
        }
        
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = currentQuestion.correctAnswer == answer
        if isCorrect {
            log.debug("The answer was correct.")
            score += 1
            return
        }
        log.debug("The answer was incorrect.")
        wrongQuestions.append(currentQuestion)
    }
    
    /// Updates to the next question.
    @MainActor
    func nextQuestion() {
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
}
