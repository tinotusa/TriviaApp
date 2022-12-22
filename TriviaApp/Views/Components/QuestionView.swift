//
//  QuestionView.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct QuestionView: View {
    private let question: TriviaQuestion
    @Binding private var hiddenAnswers: [String]
    @Binding private var selectedAnswer: String?
    private let isHiddenAnswer: (String) -> Bool
    private let questionType: TriviaAPI.TriviaType
    
    init(
        question: TriviaQuestion,
        hiddenAnswers: Binding<[String]>,
        selectedAnswer: Binding<String?> = .constant(nil),
        isHiddenAnswer: @escaping (String) -> Bool
    ) {
        self.question = question
        _hiddenAnswers = hiddenAnswers
        _selectedAnswer = selectedAnswer
        self.isHiddenAnswer = isHiddenAnswer
        questionType = .init(rawValue: question.type)!
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(questionType.title)
                .accessibilityIdentifier("Question type label")
            Text(question.question)
                .multilineTextAlignment(.center)
            
            Divider()
            
            Spacer()
            
            ForEach(Array(question.allAnswers.enumerated()), id: \.0) { (index, answer) in
                AnswerButton(
                    answer: answer,
                    isDisabled: isAnswerHidden(answer: answer),
                    isSelected: isSelected(answer)
                ) {
                    selectedAnswer = answer
                }
                .accessibilityIdentifier("Answer button\(index)")
                .disabled(isAnswerHidden(answer: answer))
            }
            
            Spacer()
        }
        .bodyStyle()
    }
}

private extension QuestionView {
    func isAnswerHidden(answer: String) -> Bool {
        hiddenAnswers.contains(answer)
    }
    
    func isSelected(_ answer: String) -> Bool {
        selectedAnswer == answer
    }
}

struct QuestionView_Previews: PreviewProvider {
    struct QuestionViewContainer: View {
        @State private var hiddenAnswers: [String] = []
        @State private var selectedAnswer: String?
        @State private var isHiddenAnswer: (String) -> Bool = { _ in
            true
        }
        @State private var questions: [TriviaQuestion] = []
        
        var body: some View {
            QuestionView(
                question: Bundle.main.loadJSON(QuestionsResponse.self, filename: "exampleQuestions").results.first!,
                hiddenAnswers: $hiddenAnswers,
                selectedAnswer: $selectedAnswer,
                isHiddenAnswer: isHiddenAnswer
            )
        }
    }
    static var previews: some View {
        QuestionViewContainer()
    }
}
