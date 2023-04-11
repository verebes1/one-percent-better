//
//  RoundedDropDownMenuButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/14/22.
//

import SwiftUI

struct CapsuleMenuButtonLabel<Content>: View where Content: View {
   
   @Environment(\.colorScheme) var scheme
   
   var label: () -> Content
   var color: Color
   var fontSize: CGFloat = 15
   
   private var textColor: Color {
      scheme == .light ? .black : .white
   }
   
   var body: some View {
      HStack(spacing: fontSize/3.4) {
         
         label()

         Image(systemName: "chevron.down")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: fontSize * 0.35)
      }
      .fixedSize()
      .padding(.vertical, fontSize/3.5)
      .padding(.horizontal, fontSize * 0.7)
      .foregroundColor(textColor)
      .fontWeight(.medium)
      .background(color)
      .clipShape(Capsule())
   }
}

struct CapsuleMenuButton: View {
   
   @Environment(\.colorScheme) var scheme
   
   var text: String
   var color: Color
   var fontSize: CGFloat = 15
   
   private var textColor: Color {
      scheme == .light ? .white : .black
   }
   
   var body: some View {
      HStack(spacing: fontSize/3.4) {
         
         // .id(text) is necessary to get the text to animate properly
         // without .id() modifier, the text view is the same view and animates as T... Te... Tes... Test...
         Text(text)
            .font(.system(size: fontSize))
            .id(text)

         Image(systemName: "chevron.down")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: fontSize * 0.35)
      }
      .fixedSize()
      .padding(.vertical, fontSize/3.5)
      .padding(.horizontal, fontSize * 0.7)
      .foregroundColor(textColor)
      .fontWeight(.medium)
      .background(color)
      .clipShape(Capsule())
   }
}

struct CapsuleMenuButton_Previewer: View {
   
   @State private var text = "Drive"
   
   var body: some View {
      VStack {
         HStack {
            Text("Offset")
            CapsuleMenuButton(text: text,
                                      color: .blue,
                                      fontSize: 10)
            Text("both sides")
         }
         
         CapsuleMenuButton(text: text,
                                   color: .blue,
                                   fontSize: 15)
         
         
         CapsuleMenuButton(text: text,
                                   color: .blue,
                                   fontSize: 20)
         
         CapsuleMenuButton(text: text,
                                   color: .blue,
                                   fontSize: 25)
      }
      .onTapGesture {
         withAnimation(.easeInOut) {
            if text == "Drive" {
               text = "Longer text"
            } else {
               text = "Drive"
            }
         }
      }
      .scaleEffect(2.0)
   }
}

struct CapsuleMenuButton_Previews: PreviewProvider {
   static var previews: some View {
      VStack {
         CapsuleMenuButton_Previewer()
      }
   }
}
