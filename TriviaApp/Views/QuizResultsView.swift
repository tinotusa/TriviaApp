//
//  QuizResultsView.swift
//  TriviaApp
//
//  Created by Tino on 14/12/2022.
//

import SwiftUI

struct QuizResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var hapticsManager: HapticsManager
    let quizResult: TriviaResult
    
    var body: some View {
        VStack {
            Text("Score: \(quizResult.score) (\(quizResult.percentage.formatted(.percent)))")
                .mediumBodyStyle()
            
            if !quizResult.isPerfectScore {
                WrongQuestionsView(questions: quizResult.wrongQuestions)
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
            if quizResult.percentage > 50.0 {
                hapticsManager.triviaOverHaptics()
            }
        }
    }
}

struct QuizResultsView_Previews: PreviewProvider {
    static var questions = Bundle.main.loadJSON(QuestionsResponse.self, filename: "exampleQuestions").results
    static var previews: some View {
        QuizResultsView(
            quizResult: .init(
                score: 3,
                questions: questions,
                wrongQuestions: [questions[0], questions[3], questions[4]]
                
            )
        )
        .environmentObject(HapticsManager())
    }
}
