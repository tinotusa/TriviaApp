//
//  QuestionsView.swift
//  TriviaApp
//
//  Created by Tino on 13/12/2022.
//

import SwiftUI

struct QuestionsView: View {
    var questions: [TriviaQuestion] = []
    
    var body: some View {
        Text("testing")
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView(questions: [])
    }
}
