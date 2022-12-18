//
//  AnswerButton.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct AnswerButton: View {
    let answer: String
    var isDisabled: Bool
    var isSelected: Bool
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(answer)
                .frame(maxWidth: .infinity)
                .modifier(AnswerButtonStyle(isDisabled: isDisabled, isSelected: isSelected))
        }
        
        .disabled(isDisabled)
    }
}

struct AnswerButton_Previews: PreviewProvider {
    static var previews: some View {
        AnswerButton(answer: "this is a test answer", isDisabled: false, isSelected: false) {
            
        }
    }
}
