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
    @Published private(set) var quizResult: QuizResult
    @Published var selectedAnswer: String? = nil
    @Published private(set) var hiddenAnswers = [String]()
    /// Answers to hide when hint is pressed.
    private var answersLeftToHide: [String]?
    
    private let log = Logger(subsystem: "com.tinotusa.TriviaApp", category: "QuestionsViewModel")
    
    /// Creates the QuestionViewModel.
    init(questions: [TriviaQuestion]) {
        self.questions = questions
        quizResult = .init(questions: questions)
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
        clearHiddenAnswers()
        clearIncorrectAnswers()
        log.debug("Successfully submitted an answer")
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
            quizResult.score += 1
            return
        }
        log.debug("The answer was incorrect.")
        quizResult.wrongQuestions.append(currentQuestion)
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
