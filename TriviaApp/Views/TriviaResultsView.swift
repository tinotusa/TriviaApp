//
//  TriviaResultsView.swift
//  TriviaApp
//
//  Created by Tino on 14/12/2022.
//

import SwiftUI

struct TriviaResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var hapticsManager: HapticsManager
    let triviaResult: TriviaResult
    
    var body: some View {
        VStack {
            Text("Score: \(triviaResult.score) (\(triviaResult.percentage.formatted(.percent)))")
                .mediumBodyStyle()
            
            if !triviaResult.isPerfectScore {
                WrongQuestionsView(questions: triviaResult.wrongQuestions)
            } else {
                Text("Congrats.\nYou got every question right!\n😊")
                    .multilineTextAlignment(.center)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ContinueButton(isDisabled: false) {
                dismiss()
            }
        }
        .padding()
        .bodyStyle()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .onAppear {
            if triviaResult.percentage > 50.0 {
                hapticsManager.triviaOverHaptics()
            }
        }
    }
}

struct TriviaResultsView_Previews: PreviewProvider {
    static var questions = Bundle.main.loadJSON(QuestionsResponse.self, filename: "exampleQuestions").results
    static var previews: some View {
        TriviaResultsView(
            triviaResult: .init(
                score: 3,
                questions: questions,
                wrongQuestions: [questions[0], questions[3], questions[4]]
                
            )
        )
        .environmentObject(HapticsManager())
    }
}
