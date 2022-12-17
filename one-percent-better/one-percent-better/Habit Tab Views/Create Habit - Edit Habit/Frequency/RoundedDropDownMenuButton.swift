//
//  RoundedDropDownMenuButton.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/14/22.
//

import SwiftUI

struct RoundedDropDownMenuButton: View {
   
   var text: String
   var color: Color
   var fontSize: CGFloat = 15
   
   var body: some View {
      HStack(spacing: fontSize/3.4) {
         Text(text)
            .font(.system(size: fontSize))
         
         Image(systemName: "chevron.down")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: fontSize * 0.35)
      }
      .padding(.vertical, fontSize/3.5)
      .padding(.horizontal, fontSize * 0.7)
      .foregroundColor(.white)
      .background(color)
      .clipShape(Capsule())
   }
}

struct DayWeekMonthDropDown_Previews: PreviewProvider {
   static var previews: some View {
      VStack {
         RoundedDropDownMenuButton(text: "Drive all the way",
                                   color: .blue,
                                   fontSize: 10)
         
         RoundedDropDownMenuButton(text: "Drive",
                                   color: .blue,
                                   fontSize: 15)
         
         
         RoundedDropDownMenuButton(text: "Drive",
                                   color: .blue,
                                   fontSize: 20)
         
         RoundedDropDownMenuButton(text: "Drive",
                                   color: .blue,
                                   fontSize: 25)
      }
      .scaleEffect(2.0)
   }
}
