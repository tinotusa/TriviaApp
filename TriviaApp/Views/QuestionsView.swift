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
    @State private var selectedAnswer = ""
    
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
                        }
                        Spacer()
                        Text(question.question)
                        // TODO: add question card view
                        ForEach(question.allAnswers, id: \.self) { answer in
                            Button {
                                selectedAnswer = answer
                            } label: {
                                Text(answer)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Continue") {
                            _ = viewModel.checkAnswer(answer: selectedAnswer)
                            viewModel.nextQuestion()
                        }
                        .disabled(selectedAnswer.isEmpty)
                    }
                    .padding()
                }
            } else {
                QuizResultsView(quizResult: .init(
                    score: viewModel.score,
                    questions: viewModel.questions,
                    wrongQuestions: viewModel.wrongQuestions
                    )
                )
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
