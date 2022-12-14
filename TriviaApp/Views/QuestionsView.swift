//
//  QuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import SwiftUI

struct QuestionsView: View {
    @StateObject private var viewModel: QuestionsViewModel
    
    init(questions: [TriviaQuestion]) {
        _viewModel = StateObject(wrappedValue: QuestionsViewModel(questions: questions))
    }
    
    var body: some View {
        if let question = viewModel.currentQuestion {
            VStack {
                Text(question.question)
                // TODO: add question card view
                ForEach(question.allAnswers, id: \.self) { answer in
                    Button {
                        _ = viewModel.checkAnswer(answer: answer)
                        viewModel.nextQuestion()
                    } label: {
                        Text(answer)
                    }
                }
            }
        }
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView(questions: [])
    }
}
