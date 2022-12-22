//
//  WrongQuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 19/12/2022.
//

import SwiftUI

/// A list of the questions the user answered incorrectly.
///
/// This is shown in the TriviaResultsView
struct WrongQuestionsView: View {
    /// The incorrectly answered questions.
    private let questions: [TriviaQuestion]
    
    init(questions: Set<TriviaQuestion>) {
        self.questions = Array(questions)
    }
    
    var body: some View {
        VStack {
            Text("Questions you got wrong.")
                .mediumBodyStyle()
            
            ViewThatFits(in: .vertical) {
                listView
                
                GeometryReader { proxy in
                    ScrollView(showsIndicators: false) {
                        listView
                            .frame(maxWidth: proxy.size.width)
                            .frame(minHeight: proxy.size.height)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

private extension WrongQuestionsView {
    var listView: some View {
        VStack {
            ForEach(questions, id: \.self) { question in
                VStack(alignment: .leading) {
                    Text("Q: \(question.question)")
                        .padding(.bottom, 3)
                    Text("A: \(question.correctAnswer)")
                    Divider()
                }
            }
        }
    }
}

struct WrongQuestionsView_Previews: PreviewProvider {
    static let questions = Array(Bundle.main.loadJSON(QuestionsResponse.self, filename: "exampleQuestions").results[0..<3])
    
    static var previews: some View {
        WrongQuestionsView(questions: Set(questions))
    }
}
