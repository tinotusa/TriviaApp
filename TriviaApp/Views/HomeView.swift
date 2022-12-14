//
//  HomeView.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    @State private var showingQuestionsView = false
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Trivia")
                    .font(.custom("Caveat", size: 80, relativeTo: .title))
                
                Spacer()
                
                Picker("Category", selection: $viewModel.category) {
                    ForEach(TriviaAPI.TriviaCategory.allCases) { category in
                        Text(category.title)
                            .tag(category)
                    }
                }
                Stepper("Number of questions \(viewModel.numberOfQuestions)", value: $viewModel.numberOfQuestions)
                Picker("Difficulty", selection: $viewModel.difficulty) {
                    ForEach(TriviaAPI.TriviaDifficulty.allCases) { difficulty in
                        Text(difficulty.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Question type", selection: $viewModel.triviaType) {
                    ForEach(TriviaAPI.TriviaType.allCases) { type in
                        Text(type.title)
                    }
                }
                .pickerStyle(.segmented)
                
                Button {
                    Task {
                        await viewModel.generateQuestions()
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
                QuestionsView(questions: viewModel.questions)
            }
            .padding()
            .navigationDestination(for: [TriviaQuestion].self) { questions in
                QuestionsView(questions: questions)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HomeViewModel())
    }
}
