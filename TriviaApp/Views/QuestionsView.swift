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
    
    init(triviaConfig: TriviaAPI.TriviaConfig) {
        _viewModel = StateObject(wrappedValue: QuestionsViewModel(triviaConfig: triviaConfig))
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    await viewModel.getQuestions()
                }
        case .loaded:
            loadedView
        case .error(let error):
            // TODO: error view
            VStack {
                Text(error.localizedDescription)
            }
            .alert(
                "Something went wrong.",
                isPresented: $viewModel.showingAlert,
                presenting: viewModel.alert
            ) { alertDetails in
                switch alertDetails.type {
                case .seenAllQuestions:
                    Button("Reset questions") {
                        Task {
                            await viewModel.resetQuestions()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                case .noResults:
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                case .serverStatus:
                    Button("Retry") {
                        Task {
                            await viewModel.getQuestions()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                default:
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            } message: { alertDetails in
                Text(alertDetails.message)
            }
        }
    }
    
    var loadedView: some View {
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
        QuestionsView(triviaConfig: .default)
            .environmentObject(HapticsManager())
    }
}
