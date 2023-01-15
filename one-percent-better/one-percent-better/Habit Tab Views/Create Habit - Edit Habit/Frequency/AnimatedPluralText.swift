//
//  AnimatedTimesText.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/11/22.
//

import SwiftUI

struct AnimatedPluralInt: View {
   
   var text: String
   @Binding var value: Int
   
   var slideIn: AnyTransition {
      .move(edge: .bottom)
   }
   
   var body: some View {
      HStack(spacing: 0) {
         Text(text)
         if value > 1 {
            Text("s")
               .transition(.opacity.combined(with: slideIn))
         }
      }
      .animation(.easeInOut(duration: 0.3), value: value)
   }
}

struct AnimatedPluralString: View {
   
   var text: String
   @Binding var value: String
   
   var slideIn: AnyTransition {
      .move(edge: .bottom)
   }
   
   var body: some View {
      HStack(spacing: 0) {
         Text(text)
         if let value = Int(value), value > 1 {
            Text("s")
               .transition(.opacity.combined(with: slideIn))
         }
      }
      .animation(.easeInOut(duration: 0.3), value: value)
   }
}

struct AnimatedPluralText_Previewer: View {
   
   @State private var valueInt = 1
   
   @State private var valueString = "1"
   
   var body: some View {
      
      VStack {
         HStack {
            Text("Int version: ")
            AnimatedPluralInt(text: "time", value: $valueInt)
               .onTapGesture {
                  withAnimation {
                     valueInt = valueInt == 1 ? 2 : 1
                  }
               }
         }
         
         HStack {
            Text("String version: ")
            AnimatedPluralString(text: "time", value: $valueString)
               .onTapGesture {
                  withAnimation {
                     valueString = valueString == "1" ? "2" : "1"
                  }
               }
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
