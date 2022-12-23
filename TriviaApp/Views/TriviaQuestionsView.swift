//
//  QuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import SwiftUI
import SwiftOpenTDB

struct QuestionsView: View {
    @EnvironmentObject private var hapticsManager: HapticsManager
    @StateObject private var viewModel: QuestionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuitConfirmationDialog = false
    
    init(triviaConfig: TriviaConfig) {
        _viewModel = StateObject(wrappedValue: QuestionsViewModel(triviaConfig: triviaConfig))
        
    }
    
    var body: some View {
        switch viewModel.viewLoadingState {
        case .loading:
            LoadingView()
                .task {
                    if CommandLine.arguments.contains("-testing-quiz") {
                        viewModel.questions = Question.examples
                        viewModel.viewLoadingState = .loaded
                        viewModel.triviaResult.questions = Set(viewModel.questions)
                    } else {
                        await viewModel.getQuestions()
                    }
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
                }
            }
        }
    }
}

// MARK: - Subviews
private extension QuestionsView {
    func header(question: Question) -> some View {
        HStack {
            Button {
                showingQuitConfirmationDialog = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
            }
            .foregroundColor(.red)
            .accessibilityIdentifier("Quit trivia")
            
            Spacer()
            
            Button("Hint") {
                _ = viewModel.showHint()
            }
            .foregroundColor(.blue)
            .disabled(question.type == "boolean" || viewModel.hintsDisabled)
            .accessibilityIdentifier("Hint button")
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
                        
                        header(question: question)
                        
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
            .accessibilityIdentifier("Confirmation quit")
            Button("Continue", role: .cancel) {
                
            }
            .accessibilityIdentifier("Confirmation continue")
        } message: {
            Text("Are you sure you want to quit this trivia round?")
        }
        .navigationBarBackButtonHidden()
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView(triviaConfig: .default)
            .environmentObject(HapticsManager())
    }
}
