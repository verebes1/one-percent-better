//
//  AnimatedTimesText.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/11/22.
//

import SwiftUI

struct AnimatedTimesText: View {
   
   @Binding var plural: Bool
   
   var slideIn: AnyTransition {
      .move(edge: .bottom)
   }
   
   var body: some View {
      HStack(spacing: 0) {
         Text("time")
         if plural {
            Text("s")
               .transition(.opacity.combined(with: slideIn))
         }
      }
      .animation(.easeInOut(duration: 0.3), value: plural)
   }
}

struct AnimatedTimesText_Previewer: View {
   @State private var plural = true
   var body: some View {
      AnimatedTimesText(plural: $plural)
         .onTapGesture {
            withAnimation {
               plural.toggle()
            }
         }
   }
}

struct AnimatedTimesText_Previews: PreviewProvider {
   static var previews: some View {
      AnimatedTimesText_Previewer()
   }
}
