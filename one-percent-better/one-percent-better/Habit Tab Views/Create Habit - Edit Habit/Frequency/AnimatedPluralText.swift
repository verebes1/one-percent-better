//
//  AnimatedTimesText.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/11/22.
//

import SwiftUI

struct AnimatedPlural: View {
   
   let text: String
   let value: Int
   
   var slideInOpacity: AnyTransition {
      .opacity.combined(with: .move(edge: .bottom))
   }
   
   var body: some View {
      HStack(spacing: 0) {
         Text(text)
         if value > 1 {
            Text("s")
               .transition(slideInOpacity)
         }
      }
      .animation(.easeInOut(duration: 0.3), value: value)
   }
}

struct AnimatedPluralText_Previewer: View {
   
   @State private var value = 1
   
   var body: some View {
      VStack {
         AnimatedPlural(text: "time", value: value)
            .onTapGesture {
               value = value == 1 ? 2 : 1
            }
      }
   }
}

struct AnimatedPluralText_Previews: PreviewProvider {
   static var previews: some View {
      // NOTE: A VStack is necessary to get transition animations to work properly
      VStack {
         AnimatedPluralText_Previewer()
      }
   }
}
