//
//  CustomStepperButton.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct CustomStepperButton: View {
    private let label: ButtonLabel
    private let action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled
    
    init(_ label: ButtonLabel, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: label.imageName)
                .frame(minWidth: Constants.size, minHeight: Constants.size)
                .foregroundColor(!isEnabled ? .darkGray : .buttonText)
                .bodyStyle()
                .background(!isEnabled ? Color.customGray : Color.customYellow)
                .cornerRadius(Constants.cornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .foregroundColor(!isEnabled ? Color.darkGray : .darkYellow)
                        .offset(y: Constants.yOffset)
                }
        }
        .accessibilityIdentifier(label == .increment ? "Stepper increment" : "Stepper decrement")
    }
}

extension CustomStepperButton {
    /// The labels for the different types of stepper buttons.
    enum ButtonLabel {
        case increment
        case decrement
        
        /// The SF symbol name for the label.
        var imageName: String {
            switch self {
            case .increment: return "plus"
            case .decrement: return "minus"
            }
        }
    }
    
    /// Constants for this view.
    enum Constants {
        /// The corner radius of the button.
        static let cornerRadius = 10.0
        /// The size(width and height) of the button.
        static let size = 40.0
        /// The y offset of the background shadow effect.
        static let yOffset = 4.0
    }
}

struct CustomStepperButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // enabled buttons
            HStack {
                CustomStepperButton(.increment) {
                    
                }
                CustomStepperButton(.decrement) {
                    
                }
            }
            // Disabled buttons
            HStack {
                CustomStepperButton(.increment) {
                    
                }
                CustomStepperButton(.decrement) {
                    
                }
            }
            .disabled(true)
        }
    }
}
