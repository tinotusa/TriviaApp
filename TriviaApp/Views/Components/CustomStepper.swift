//
//  CustomStepper.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI
import Combine

struct CustomStepper: View {
    @Binding var value: Int
    @State private var stringValue = ""
    private let minValue: Int
    private let maxValue: Int
    
    init(value: Binding<Int>, minValue: Int = 0, maxValue: Int = 50) {
        _value = value
        _stringValue = State(wrappedValue: "\(value.wrappedValue)")
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    var body: some View {
        HStack {
            CustomStepperButton(.increment) {
                updateValue(by: 1)
            }
            .disabled(isDisabled(.increment))
            
            TextField("Value", text: $stringValue)
                .onReceive(Just(stringValue)) { newValue in
                    let filteredValue = newValue.filter { Set("0123456789").contains($0) }
                    if filteredValue != newValue {
                        self.stringValue = filteredValue
                    }
                }
                .onChange(of: stringValue) { newValue in
                    if let value = Int(newValue) {
                        self.value = min(maxValue, max(minValue, value))
                        stringValue = "\(self.value)"
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: 30)
                .labelsHidden()
                .keyboardType(.numberPad)
                .accessibilityIdentifier("Stepper textField")
            
            CustomStepperButton(.decrement) {
                updateValue(by: -1)
            }
            .disabled(isDisabled(.decrement))
        }
        .bodyStyle()
    }
}

private extension CustomStepper {
    /// Increments the value by the given amount.
    /// - Parameter amount: The amount to increment by.
    func updateValue(by amount: Int) {
        self.value += amount
        self.value = min(maxValue, max(self.value, minValue))
        stringValue = "\(self.value)"
    }
    
    /// Checks to see if a stepper button has reached it's min or max value,
    /// and returns `true` if it has.
    ///
    /// - Parameter label: The label to check for.
    /// - Returns: `true` is that label has hit its min or max value; `false` otherwise.
    func isDisabled(_ label: CustomStepperButton.ButtonLabel) -> Bool {
        switch label {
        case .decrement: return value == minValue
        case .increment: return value == maxValue
        }
    }
}

struct CustomStepper_Previews: PreviewProvider {
    struct CustomStepperContainer: View {
        @State private var value = 0
        
        var body: some View {
            CustomStepper(value: $value)
        }
    }
    
    static var previews: some View {
        CustomStepperContainer()
    }
}
