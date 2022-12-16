//
//  TimesADayText.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/11/22.
//

import SwiftUI

struct TimesADayText: View {
   
   @Binding var plural: Bool
   
   var slideIn: AnyTransition {
      .move(edge: .bottom)
//      .animation(.easeInOut(duration: 2.0))
   }
   
   var body: some View {
      HStack(spacing: 0) {
         Text("time")
         if plural {
            Text("s")
               .transition(.opacity.combined(with: slideIn))
//               .transition(.opacity.animation(.easeIn(duration: 2.0)))
//               .transition(.move(edge: .bottom).combined(with: .opacity))
         }
         Text(" a day")
      }
      .frame(minWidth: 100)
//      .background(.red.opacity(0.2))
      .animation(.easeInOut(duration: 0.3), value: plural)
   }
}

struct TimesADayText_Previewer: View {
   @State private var plural = true
   var body: some View {
      TimesADayText(plural: $plural)
         .onTapGesture {
            withAnimation {
               plural.toggle()
            }
         }
   }
}

struct TimesADayText_Previews: PreviewProvider {
   static var previews: some View {
      TimesADayText_Previewer()
   }
}
