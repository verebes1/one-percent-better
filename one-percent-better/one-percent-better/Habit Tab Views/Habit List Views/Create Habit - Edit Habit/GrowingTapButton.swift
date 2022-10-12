//
//  GrowingTapButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/12/22.
//

import SwiftUI

struct GrowingTapButton: View {
    var body: some View {
       Button {
          // do nothing
       } label: {
          Text("Hello World!")
       }

    }
}

struct GrowingTapButtonStyle: ButtonStyle {
   
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

struct GrowingTapButton_Previews: PreviewProvider {
    static var previews: some View {
        GrowingTapButton()
    }
}
