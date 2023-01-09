//
//  RoundedDropDownMenuButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/14/22.
//

import SwiftUI

struct RoundedDropDownMenuButton: View {
   
   @Binding var text: String
   var color: Color
   var fontSize: CGFloat = 15
   
   var body: some View {
      HStack(spacing: fontSize/3.4) {
         
         // .id(text) is necessary to get the text to animate properly
         // without .id() modifier, the text view animates with ... as it grows
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
      .foregroundColor(.white)
      .fontWeight(.medium)
      .background(color)
      .clipShape(Capsule())
   }
}

struct DayWeekMonthDropDown_Previewer: View {
   
   @State private var text = "Drive"
   
   var body: some View {
      VStack {
         HStack {
            Text("Offset")
            RoundedDropDownMenuButton(text: $text,
                                      color: .blue,
                                      fontSize: 10)
            Text("both sides")
         }
         
         RoundedDropDownMenuButton(text: $text,
                                   color: .blue,
                                   fontSize: 15)
         
         
         RoundedDropDownMenuButton(text: $text,
                                   color: .blue,
                                   fontSize: 20)
         
         RoundedDropDownMenuButton(text: $text,
                                   color: .blue,
                                   fontSize: 25)
      }
      .onTapGesture {
         withAnimation(.easeInOut(duration: 3)) {
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

struct DayWeekMonthDropDown_Previews: PreviewProvider {
   static var previews: some View {
      DayWeekMonthDropDown_Previewer()
   }
}
