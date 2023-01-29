//
//  CapsuleButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/23/23.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
   
   @Environment(\.colorScheme) var scheme
   
   var fontSize = 15.0
   var color: Color = .blue
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
   
   func makeBody(configuration: Configuration) -> some View {
      configuration.label
         .padding(.vertical, fontSize/3.5)
         .padding(.horizontal, fontSize * 0.7)
         .foregroundColor(textColor)
         .fontWeight(.medium)
         .background(color)
         .clipShape(Capsule())
         .scaleEffect(configuration.isPressed ? 0.95 : 1)
         .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
   }
}

struct CapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
       Button("Stupendous anarchy") {
          // do nothing
       }
       .buttonStyle(CapsuleButtonStyle())
    }
}
