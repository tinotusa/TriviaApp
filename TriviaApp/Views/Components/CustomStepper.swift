//
//  CustomStepper.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

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
            CustomStepperButton(.plus) {
                updateValue(by: 1)
            }
            
            TextField("Value", text: $stringValue)
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
                
            CustomStepperButton(.minus) {
                updateValue(by: -1)
            }
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
