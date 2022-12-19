//
//  TriviaQuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import SwiftUI

struct TriviaQuestionsView: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    @StateObject private var viewModel: TriviaQuestionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuitConfirmationDialog = false
    
    init(triviaConfig: TriviaAPI.TriviaConfig) {
        _viewModel = StateObject(wrappedValue: TriviaQuestionsViewModel(triviaConfig: triviaConfig))
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
        case .error:
            ErrorView(title: "Something went wrong.", detail: viewModel.alert != nil ? viewModel.alert!.message : "Something went wrong") {
                if let alertDetails = viewModel.alert {
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
                } else {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension TriviaQuestionsView {
    func header(questionType: String) -> some View {
        HStack {
            Button {
                showingQuitConfirmationDialog = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
            }
            .foregroundColor(.red)
            
            Spacer()
            
            Button("Hint") {
                viewModel.showHint()
            }
            .foregroundColor(.blue)
            .disabled(questionType == "boolean" || viewModel.hintsDisabled)
        }
        .bodyStyle()
    }
    
    var loadedView: some View {
        Group {
            if !viewModel.isTriviaRoundOver {
                if let question = viewModel.currentQuestion {
                    VStack {
                        let questionView = QuestionView(
                            question: question,
                            hiddenAnswers: $viewModel.hiddenAnswers,
                            selectedAnswer: $viewModel.selectedAnswer,
                            isHiddenAnswer: viewModel.isAnswerHidden
                        )
                        
                        header(questionType: question.type)
                        
                        ViewThatFits(in: .vertical) {
                            questionView
                            
                            ScrollView(showsIndicators: false) {
                                questionView
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        ContinueButton(isDisabled: !viewModel.hasSelectedAnswer) {
                            let isCorrect = viewModel.submitAnswer()
                            if isCorrect {
                                hapticsManager.correctAnswerHaptic()
                            }
                        }
                        .disabled(!viewModel.hasSelectedAnswer)
                    }
                    .bodyStyle()
                    .padding()
                }
            } else {
                TriviaResultsView(triviaResult: viewModel.triviaResult)
                    .transition(.move(edge: .bottom))
            }
        }
        .background(Color.background)
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

struct TriviaQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaQuestionsView(triviaConfig: .default)
            .environmentObject(HapticsManager())
    }
}
