//
//  MyStepper.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import SwiftUI

struct MyStepper: View {
    
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    private var enableIncrement: Bool {
        value < range.upperBound
    }
    
    private var enableDecrement: Bool {
        value > range.lowerBound
    }
    
    private let backgroundColor = Color(#colorLiteral(red: 0.9310173988, green: 0.9355356693, blue: 0.935390532, alpha: 1))
    private let separatorColor = Color(#colorLiteral(red: 0.8372157812, green: 0.8420629501, blue: 0.8492249846, alpha: 1))
    private let selectedColor = Color(#colorLiteral(red: 0.7734330297, green: 0.7784343362, blue: 0.7932845354, alpha: 1))
    private let disabledColor = Color(#colorLiteral(red: 0.4678601623, green: 0.4678601623, blue: 0.4678601623, alpha: 1))
    private let enabledColor = Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    
    func increment() {
        if value < range.upperBound {
            value += 1
        }
        
    }
    
    func decrement() {
        if value > range.lowerBound {
            value -= 1
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(backgroundColor)

                HStack(spacing: 0) {
                    
                    Button {
                        decrement()
                    } label: {
                        Color.clear
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(StepperButtonStyle(enabled: enableDecrement))

                    Button {
                        increment()
                    } label: {
                        Color.clear
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(StepperButtonStyle(enabled: enableIncrement))
                }

                HStack(spacing: 16) {
                    Image(systemName: "minus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .foregroundColor(enableDecrement ? enabledColor : disabledColor)
                    
                    Rectangle()
                        .frame(height: 18)
                        .frame(width: 1)
                        .foregroundColor(separatorColor)
                    
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .foregroundColor(enableIncrement ? enabledColor : disabledColor)
                }
            }
            .frame(width: 94)
            .frame(height: 32)
        }
    }
}

struct StepperButtonStyle: ButtonStyle {
    
    var enabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                enabled ?
                RoundedRectangle(cornerRadius: 7)
                    .foregroundColor(configuration.isPressed ? .systemGray2.opacity(0.9) : .clear)
                :
                    nil
            )
    }
}

struct MyStepperPreviewer: View {
    @State private var value: Int = 1
    var body: some View {
        MyStepper(value: $value, range: 1 ... 10)
    }
}


struct MyStepper_Previews: PreviewProvider {
    static var previews: some View {
        MyStepperPreviewer()
    }
}
