//
//  HomeView.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingQuestionsView = false
    @State private var showingCreditsSheet = false
    
    // MARK: - Body
    var body: some View {
        ViewThatFits(in: .vertical) {
            menuOptions
            ScrollView(showsIndicators: false) {
                menuOptions
            }
            .background(Color.background)
        }
        .fullScreenCover(isPresented: $showingQuestionsView) {
            QuestionsView(triviaConfig: viewModel.triviaConfig)
        }
        .sheet(isPresented: $showingCreditsSheet) {
            CreditsView()
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Subviews
private extension HomeView {
    var menuOptions: some View {
        VStack {
            Text("Trivia")
                .titleStyle()
            
            categoryRow
            
            questionAmountRow
            
            difficultyRow
            
            questionTypeRow
            
            Button {
                showingQuestionsView = true
            } label: {
                Text("Start Trivia")
                    .startButtonStyle()
            }
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            header
        }
        .padding()
        .background(Color.background)
    }
    
    var header: some View {
        HStack {
            Spacer()
            Button("Credits") {
                showingCreditsSheet = true
            }
        }
    }
    
    var categoryRow: some View {
        HStack {
            Text("Category")
            Spacer()
            Picker("Category", selection: $viewModel.triviaConfig.category) {
                ForEach(TriviaAPI.TriviaCategory.allCases) { category in
                    Text(category.title)
                        .tag(category)
                }
            }
        }
        .bodyStyle()
    }
    
    var questionAmountRow: some View {
        HStack {
            Text("Number of questions")
            Spacer()
            CustomStepper(value: $viewModel.triviaConfig.numberOfQuestions)
        }
        .bodyStyle()
    }
    
    var difficultyRow: some View {
        HStack {
            Text("Difficulty")
            Spacer()
            Picker("Difficulty", selection: $viewModel.triviaConfig.difficulty) {
                ForEach(TriviaAPI.TriviaDifficulty.allCases) { difficulty in
                    Text(difficulty.title)
                }
            }
        }
        .bodyStyle()
    }
    
    var questionTypeRow: some View {
        HStack {
            Text("Question type")
            Spacer()
            Picker("Question type", selection: $viewModel.triviaConfig.triviaType) {
                ForEach(TriviaAPI.TriviaType.allCases) { type in
                    Text(type.title)
                }
            }
        }
        .bodyStyle()
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
