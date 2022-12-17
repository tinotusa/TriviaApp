//
//  HomeView.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var hapticsManger: HapticsManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingQuestionsView = false
    @State private var showingCreditsSheet = false
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    Spacer()
                    Button("Credits") {
                        showingCreditsSheet = true
                    }
                }
                Spacer()
            }
            Text("Trivia")
                .font(.custom("Caveat", size: 80, relativeTo: .title))
            
            Spacer()
            
            Picker("Category", selection: $viewModel.triviaConfig.category) {
                ForEach(TriviaAPI.TriviaCategory.allCases) { category in
                    Text(category.title)
                        .tag(category)
                }
            }
            
            Stepper(
                "Number of questions \(viewModel.triviaConfig.numberOfQuestions)",
                value: $viewModel.triviaConfig.numberOfQuestions
            )
            
            Picker("Difficulty", selection: $viewModel.triviaConfig.difficulty) {
                ForEach(TriviaAPI.TriviaDifficulty.allCases) { difficulty in
                    Text(difficulty.title)
                }
            }
            .pickerStyle(.segmented)
            
            Picker("Question type", selection: $viewModel.triviaConfig.triviaType) {
                ForEach(TriviaAPI.TriviaType.allCases) { type in
                    Text(type.title)
                }
            }
            .pickerStyle(.segmented)
            
            Button {
                Task {
                    await viewModel.generateQuestions()
                    hapticsManger.buttonPressHaptic()
                }
            } label: {
                Text("Generate questions")
            }
            
            Spacer()
            
            Button("Start quiz") {
                showingQuestionsView = true
            }
            .disabled(viewModel.questions.isEmpty)
        }
        .disabled(viewModel.isLoading)
        .fullScreenCover(isPresented: $showingQuestionsView) {
            viewModel.clearQuestions()
        } content: {
            QuestionsView(questions: viewModel.questions)
        }
        .sheet(isPresented: $showingCreditsSheet) {
            CreditsView()
                .presentationDragIndicator(.visible)
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
                        await viewModel.resetToken()
                    }
                }
                Button("Cancel", role: .cancel) {
                    
                }
            case .noResults:
                Button("Cancel", role: .cancel) {
                    
                }
            case .serverStatus:
                Button("Retry") {
                    Task {
                        await viewModel.generateQuestions()
                    }
                }
                Button("Cancel", role: .cancel) {
                    
                }
            default:
                Button("Cancel", role: .cancel) {
                    
                }
            }
        } message: { alertDetails in
            Text(alertDetails.message)
        }
        .padding()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HapticsManager())
    }
}
