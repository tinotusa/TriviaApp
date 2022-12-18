//
//  CustomStepperButton.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct CustomStepperButton: View {
    let label: ButtonLabel
    let action: () -> Void
    
    private let verticalPadding = 4.0
    private let cornerRadius = 10.0
    
    init(_ label: ButtonLabel, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label.label)
                .padding(.horizontal)
                .padding(.vertical, verticalPadding)
                .foregroundColor(.buttonText)
                .bodyStyle()
                .background(Color.customYellow)
                .cornerRadius(cornerRadius)
                .background {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(.darkYellow)
                        .offset(y: 4)
                }
        }
    }
}

extension CustomStepperButton {
    enum ButtonLabel {
        case plus
        case minus
        
        var label: String {
            switch self {
            case .minus: return "-"
            case .plus: return "+"
            }
        }
    }
    
}

struct CustomStepperButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomStepperButton(.plus) {
            
        }
    }
}
