//
//  MinusStepper.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/12/22.
//

import SwiftUI

struct MinusStepper: View {
   
   @Binding var value: Int
   let range: ClosedRange<Int>
   let onDecrement: (Int) -> Void
   
   private var enableDecrement: Bool {
      value > range.lowerBound
   }
   
   private let backgroundColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0.9310173988, green: 0.9355356693, blue: 0.935390532, alpha: 1)), dark: Color(#colorLiteral(red: 0.1921563745, green: 0.1921573281, blue: 0.2135840654, alpha: 1)))
   private let selectedColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0.7734330297, green: 0.7784343362, blue: 0.7932845354, alpha: 1)), dark: Color(#colorLiteral(red: 0.2675395012, green: 0.2625788152, blue: 0.2755606174, alpha: 1)))
   private let disabledColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0.4678601623, green: 0.4678601623, blue: 0.4678601623, alpha: 1)), dark: Color(#colorLiteral(red: 0.5960781574, green: 0.5960787535, blue: 0.6089832187, alpha: 1)))
   private let enabledColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), dark: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
   
   func decrement() {
      if value > range.lowerBound {
         value -= 1
         onDecrement(value)
      }
   }
   
    var body: some View {
       Button {
          decrement()
       } label: {
          ZStack {
             RoundedRectangle(cornerRadius: 8)
                .foregroundColor(backgroundColor)
             
             Image(systemName: "minus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15)
                .foregroundColor(enableDecrement ? enabledColor : disabledColor)
          }
       }
       .frame(idealWidth: 60, idealHeight: 40)
       .buttonStyle(StepperButtonStyle(enabled: enableDecrement))
    }
}

struct MinusStepperPreviewer: View {
   @State private var value = 5
   var body: some View {
      VStack {
         Text("Value: \(value)")
         MinusStepper(value: $value, range: 1...10) { v in
            // do nothing
         }
         .fixedSize()
         
         Button {
            value = 5
         } label: {
            Text("Reset")
         }

      }
    }
}

struct MinusStepper_Previews: PreviewProvider {
    static var previews: some View {
       MinusStepperPreviewer()
    }
}
