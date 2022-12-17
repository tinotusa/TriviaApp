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
            
            Spacer()
            
            Button("Start quiz") {
                showingQuestionsView = true
            }
        }
        .fullScreenCover(isPresented: $showingQuestionsView) {
            QuestionsView(triviaConfig: viewModel.triviaConfig)
        }
        .sheet(isPresented: $showingCreditsSheet) {
            CreditsView()
                .presentationDragIndicator(.visible)
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
