//
//  HomeView.swift
//  TriviaApp
//
//  Created by Tino on 4/12/2022.
//

import SwiftUI

struct HomeView: View {
    @State private var token: String?
    
    var body: some View {
        VStack {
            Text("Trivia")
                .font(.custom("Caveat", size: 80, relativeTo: .title))
            if let token {
                Text("Token: \(token)")
            }
        }
        .padding()
        .onAppear {
            let api = TriviaAPI.shared
            api.triviaConfig = .init(
                numberOfQuestions: 10,
                category: .anyCategory,
                difficulty: .easy,
                triviaType: .multipleChoice
            )
            Task {
                do {
                    let questions = try await api.getQuestions()
                    print("number of questions: ", questions.count)
                    for question in questions {
                        print(question.question)
                    }
                    token = api.sessionToken
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
