//
//  ButtonStyles.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

/// Test view for the button styles
///
/// Shouldn't need to call this view
struct ButtonStyles: View {
    @State private var isDisabled = false
    @State private var isSelected = false
    
    var body: some View {
        VStack {
            Button {
                isDisabled.toggle()
            } label: {
                Text("Start quiz")
                    .startButtonStyle()
                    .mediumBodyStyle()
            }
    
            ContinueButton(isDisabled: isDisabled) {
                
            }
            
            Button("select answer") {
                isSelected.toggle()
            }
            
            AnswerButton(answer: "this is a \n new line.", isDisabled: isDisabled, isSelected: isSelected) {
                
            }
        }
        .padding()
    }
}

struct AnswerButtonStyle: ViewModifier {
    private let cornerRadius = 6.0
    private let yOffset = 4.0
    private let isDisabled: Bool
    private let isSelected: Bool
    
    init(isDisabled: Bool, isSelected: Bool) {
        self.isDisabled = isDisabled
        self.isSelected = isSelected
    }
    
    func body(content: Content) -> some View {
        if isSelected {
            content
                .bodyStyle()
                .padding()
                .foregroundColor(.buttonText)
                .background(Color.customGreen)
                .cornerRadius(cornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(.darkGreen)
                        .offset(y: yOffset)
                }
        } else {
            content
                .bodyStyle()
                .padding()
                .foregroundColor(isDisabled ? .darkGray : .buttonText)
                .background(isDisabled ? Color.customGray : .answerButton)
                .cornerRadius(cornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(isDisabled ? .darkGray : .answerButtonStroke)
                        .offset(y: yOffset)
                }
        }
    }
}


struct CustomButtonStyle: ViewModifier {
    private let cornerRadius = 6.0
    private let yOffset = 4.0
    private let backgroundColor: Color
    private let borderColor: Color
    private let isDisabled: Bool
    
    init(backgroundColor: Color, borderColor: Color, isDisabled: Bool) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.isDisabled = isDisabled
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundColor(isDisabled ? .darkGray : .buttonText)
            .background(isDisabled ? Color.customGray : backgroundColor)
            .cornerRadius(cornerRadius)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(isDisabled ? .darkGray : borderColor)
                    .offset(y: yOffset)
            }
    }
}


extension View {
    func startButtonStyle(isDisabled: Bool = false) -> some View {
        modifier(CustomButtonStyle(backgroundColor: .customYellow, borderColor: .darkYellow, isDisabled: isDisabled))
    }
    
    func continueButtonStyle(isDisabled: Bool = false) -> some View {
        modifier(CustomButtonStyle(backgroundColor: .customGreen, borderColor: .darkGreen, isDisabled: isDisabled))
    }
    
    func answerButtonStyle(isDisabled: Bool = false, isSelected: Bool = false) -> some View {
        modifier(
            CustomButtonStyle(
                backgroundColor: isDisabled ? .customGray : .answerButton,
                borderColor: isDisabled ? .darkGray : .answerButtonStroke,
                isDisabled: isDisabled
            )
        )
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        ButtonStyles()
    }
}
