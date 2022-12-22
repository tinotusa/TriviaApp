//
//  StartTriviaButton.swift
//  TriviaApp
//
//  Created by Tino on 22/12/2022.
//

import SwiftUI

struct StartTriviaButton: View {
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Start Trivia")
                .padding()
                .foregroundColor(!isEnabled ? .darkGray : .buttonText)
                .background(!isEnabled ? Color.customGray : Color.customYellow)
                .cornerRadius(Constants.cornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .foregroundColor(!isEnabled ? .darkGray : Color.darkYellow)
                        .offset(y: Constants.yOffset)
                }
        }
        .mediumBodyStyle()
    }
}

private extension StartTriviaButton {
    enum Constants {
        static let cornerRadius = 10.0
        static let yOffset = 4.0
    }
}

struct StartTriviaButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StartTriviaButton() {
                // nothing
            }
            StartTriviaButton() {
                // nothing
            }
            .disabled(true)
        }
    }
}
