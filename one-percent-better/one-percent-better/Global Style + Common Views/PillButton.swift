//
//  PillButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/7/22.
//

import SwiftUI

struct PillButton: View {
    var body: some View {
       Button {
          print("pressed")
       } label: {
          Text("Gargantuan Bubble Tea")
       }
       .buttonStyle(PillButtonStyle(color: .purple))
       .buttonStyle(.bordered)

    }
}

struct PillButtonStyle: ButtonStyle {
   
   var color: Color
   
   func makeBody(configuration: Configuration) -> some View {
      configuration.label
         .padding()
         .background(color)
         .foregroundColor(.white)
         .opacity(configuration.isPressed ? 0.75 : 1)
         .brightness(configuration.isPressed ? 0.25 : 0)
         .clipShape(Capsule())
   }
}

struct PillButton_Previews: PreviewProvider {
    static var previews: some View {
        PillButton()
    }
}
