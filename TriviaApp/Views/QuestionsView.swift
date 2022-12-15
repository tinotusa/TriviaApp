//
//  QuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import SwiftUI

struct QuestionsView: View {
    @StateObject private var viewModel: QuestionsViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(questions: [TriviaQuestion]) {
        _viewModel = StateObject(wrappedValue: QuestionsViewModel(questions: questions))
    }
    
    var body: some View {
        Group {
            if !viewModel.isQuizOver {
                if let question = viewModel.currentQuestion {
                    VStack {
                        // TODO: move to own view
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title3)
                            }
                            Spacer()
                            Button("Hint") {
                                viewModel.showHint()
                            }
                            .disabled(question.type == "boolean" || viewModel.hintsDisabled)
                        }
                        Spacer()
                        Text(question.question)
                        // TODO: add question card view
                        ForEach(question.allAnswers, id: \.self) { answer in
                            Button {
                                viewModel.selectedAnswer = answer
                            } label: {
                                Text(answer)
                            }
                            .disabled(viewModel.isAnswerHidden(answer: answer))
                        }
                        
                        Spacer()
                        
                        Button("Continue") {
                            viewModel.submitAnswer()
                        }
                        .disabled(!viewModel.hasSelectedAnswer)
                    }
                    .padding()
                }
            } else {
                QuizResultsView(quizResult: viewModel.quizResult)
                .transition(.move(edge: .bottom))
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var questions: [TriviaQuestion] {
        let result: QuestionsResponse = Bundle.main.loadJSON(filename: "exampleQuestions")
        return result.results
    }
    
    static var previews: some View {
        QuestionsView(questions: questions)
    }
}
