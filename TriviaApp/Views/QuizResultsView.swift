//
//  QuizResultsView.swift
//  TriviaApp
//
//  Created by Tino on 14/12/2022.
//

import SwiftUI

struct QuizResultsView: View {
    @Environment(\.dismiss) private var dismiss
    let quizResult: QuizResult
    
    var body: some View {
        VStack {
            Text("Score: \(quizResult.score) (\(quizResult.percentage.formatted(.percent)))")
            
            Button("Continue") {
                dismiss()
            }
        }
    }
}

struct QuizResultsView_Previews: PreviewProvider {
    static var previews: some View {
        QuizResultsView(quizResult: .init(score: 0, questions: [], wrongQuestions: []))
    }
}
