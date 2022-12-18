//
//  QuestionView.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct QuestionView: View {
    let question: TriviaQuestion
    @Binding var hiddenAnswers: [String]
    @Binding var selectedAnswer: String?
    let isHiddenAnswer: (String) -> Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(question.question)
                .multilineTextAlignment(.center)
            
            Divider()
            
            Spacer()
            
            ForEach(question.allAnswers, id: \.self) { answer in
                AnswerButton(
                    answer: answer,
                    isDisabled: isAnswerHidden(answer: answer),
                    isSelected: isSelected(answer)
                ) {
                    selectedAnswer = answer
                }
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
