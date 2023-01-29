//
//  PlusStepper.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/12/22.
//

import SwiftUI

struct PlusStepper: View {
   
   @Binding var value: Int
   let range: ClosedRange<Int>
   let onIncrement: (Int) -> Void
   
   private var enableIncrement: Bool {
      value < range.upperBound
   }
   
   private let backgroundColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0.9310173988, green: 0.9355356693, blue: 0.935390532, alpha: 1)), dark: Color(#colorLiteral(red: 0.1921563745, green: 0.1921573281, blue: 0.2135840654, alpha: 1)))
   private let selectedColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0.7734330297, green: 0.7784343362, blue: 0.7932845354, alpha: 1)), dark: Color(#colorLiteral(red: 0.2675395012, green: 0.2625788152, blue: 0.2755606174, alpha: 1)))
   private let disabledColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0.4678601623, green: 0.4678601623, blue: 0.4678601623, alpha: 1)), dark: Color(#colorLiteral(red: 0.5960781574, green: 0.5960787535, blue: 0.6089832187, alpha: 1)))
   private let enabledColor = Color.dynamicColor(light: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)), dark: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
   
   func increment() {
      if value < range.upperBound {
         value += 1
         onIncrement(value)
      }
   }
   
    var body: some View {
       Button {
          increment()
       } label: {
          ZStack {
             RoundedRectangle(cornerRadius: 8)
                .foregroundColor(backgroundColor)
             
             Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15)
                .foregroundColor(enableIncrement ? enabledColor : disabledColor)
          }
       }
       .frame(idealWidth: 60, idealHeight: 40)
       .buttonStyle(StepperButtonStyle(enabled: enableIncrement))
    }
}

struct PlusStepperPreviewer: View {
   @State private var value = 5
   var body: some View {
      VStack {
         Text("Value: \(value)")
         PlusStepper(value: $value, range: 1...10) { v in
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

struct PlusStepper_Previews: PreviewProvider {
    static var previews: some View {
       PlusStepperPreviewer()
    }
}
