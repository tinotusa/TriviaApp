//
//  ContinueButton.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct ContinueButton: View {
    @Binding var isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("Continue quiz")
                .continueButtonStyle(isDisabled: isDisabled)
                .mediumBodyStyle()
        }
        .disabled(isDisabled)
    }
}

struct ContinueButton_Previews: PreviewProvider {
    static var previews: some View {
        ContinueButton(isDisabled: .constant(false)) {
            
        }
    }
}
