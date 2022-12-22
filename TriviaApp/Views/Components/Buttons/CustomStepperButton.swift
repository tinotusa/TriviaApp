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
    
    @State private var timer: Timer?
    @State private var isLongPressing = false
    
    init(_ label: ButtonLabel, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button {
            if isLongPressing {
                isLongPressing.toggle()
                timer?.invalidate()
            } else {
                action()
            }
        } label: {
            Image(systemName: label.imageName)
                .frame(minWidth: Constants.size, minHeight: Constants.size)
                .foregroundColor(.buttonText)
                .bodyStyle()
                .background(Color.customYellow)
                .cornerRadius(Constants.cornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .foregroundColor(.darkYellow)
                        .offset(y: Constants.yOffset)
                }
        }
        .simultaneousGesture(
            LongPressGesture()
                .onChanged { _ in
                    print("gesture changed")
                }
                .onEnded { _ in
                    isLongPressing = true
                    print("in gesture end")
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                        action()
                    }
                }
         )
        .accessibilityIdentifier(label == .increment ? "Stepper increment" : "Stepper decrement")
    }
}

extension CustomStepperButton {
    enum ButtonLabel {
        case increment
        case decrement
        
        var imageName: String {
            switch self {
            case .increment: return "plus"
            case .decrement: return "minus"
            }
        }
    }
    
    enum Constants {
        static let cornerRadius = 10.0
        static let size = 40.0
        static let yOffset = 4.0
    }
}

struct CustomStepperButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            // enabled buttons
            VStack {
                CustomStepperButton(.increment) {
                    
                }
                CustomStepperButton(.increment) {
                    
                }
            }
            // Disabled buttons
            VStack {
                CustomStepperButton(.decrement) {
                    
                }
                CustomStepperButton(.decrement) {
                    
                }
            }
            .disabled(true)
        }
    }
}
