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
                
                Button {
                    Task {
                        await viewModel.generateQuestions()
                    }
                } label: {
                    Text("Generate questions")
                }
                
                Spacer()
                // TODO: Make in to fullscreen cover
                NavigationLink(value: viewModel.questions) {
                    Text("Start quiz")
                }
                .disabled(viewModel.questions.isEmpty)
                
                Spacer()
            }
            .disabled(viewModel.isLoading)
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
