//
//  QuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import SwiftUI

struct QuestionsView: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    @StateObject private var viewModel: QuestionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuitConfirmationDialog = false
    
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
                                showingQuitConfirmationDialog = true
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
                                hapticsManager.buttonPressHaptic()
                            } label: {
                                Text(answer)
                            }
                            .disabled(viewModel.isAnswerHidden(answer: answer))
                        }
                        
                        Spacer()
                        
                        Button("Continue") {
                            let isCorrect = viewModel.submitAnswer()
                            if isCorrect {
                                hapticsManager.correctAnswerHaptic()
                            }
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
        .confirmationDialog("Quit trivia round", isPresented: $showingQuitConfirmationDialog) {
            Button("Quit", role: .destructive) {
                dismiss()
            }
            Button("Continue", role: .cancel) {
                
            }
        } message: {
            Text("Are you sure you want to quit this trivia round?")
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
            .environmentObject(HapticsManager())
    }
}
