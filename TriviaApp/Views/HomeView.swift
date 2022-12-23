//
//  HomeView.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI
import SwiftOpenTDB

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingQuestionsView = false
    @State private var showingCreditsSheet = false
    
    // MARK: - Body
    var body: some View {
        menuOptions
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
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Trivia")
                        .titleStyle()
                    
                    categoryRow

                    questionAmountRow

                    difficultyRow

                    questionTypeRow

                    StartTriviaButton {
                        showingQuestionsView = true
                    }
                    .accessibilityIdentifier("Start trivia")
                    .disabled(viewModel.startDisabled)
                }
                .frame(maxWidth: proxy.size.width)
                .frame(maxHeight: proxy.size.height)
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color.background)
            .safeAreaInset(edge: .top) {
                    header
                    .padding()
            }
        }
    }
    
    var header: some View {
        HStack {
            Spacer()
            Button("Credits") {
                showingCreditsSheet = true
            }
            .accessibilityIdentifier("Credits button")
        }
    }
    
    var categoryRow: some View {
        HStack {
            Text("Category")
            Spacer()
            Picker("Category", selection: $viewModel.triviaConfig.category) {
                ForEach(TriviaCategory.allCases) { category in
                    let title = category.title
                    Text(title)
                        .tag(category)
                        .accessibilityIdentifier(title)
                }
            }
            .accessibilityIdentifier("Category Picker")
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
                ForEach(TriviaDifficulty.allCases) { difficulty in
                    Text(difficulty.title)
                }
            }
            .accessibilityIdentifier("Difficulty Picker")
        }
        .bodyStyle()
    }
    
    var questionTypeRow: some View {
        HStack {
            Text("Question type")
            Spacer()
            Picker("Question type", selection: $viewModel.triviaConfig.triviaType) {
                ForEach(TriviaType.allCases) { type in
                    Text(type.title)
                }
            }
            .accessibilityIdentifier("Question type picker")
        }
        .bodyStyle()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
