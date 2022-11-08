//
//  RoundedRectButtonStyle.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/7/22.
//

import SwiftUI

struct RoundedRectButtonStyle: ButtonStyle {
   
   var cornerRadius: CGFloat
   var color: Color
   
   func makeBody(configuration: Configuration) -> some View {
      configuration.label
         .padding()
         .foregroundColor(.white)
         .background(color)
         .opacity(configuration.isPressed ? 0.75 : 1)
         .brightness(configuration.isPressed ? 0.1 : 0)
         .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
   }
}

struct RoundedRectButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
       Button("Stupendous anarchy") {
          // do nothing
       }
       .buttonStyle(RoundedRectButtonStyle(cornerRadius: 10,
                                           color: .purple))
    }
}
