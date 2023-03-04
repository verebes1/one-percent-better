//
//  HabitCreationHeader.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI

struct HabitCreationHeader: View {
   
   let systemImage: String
   let title: String
   var subtitle: String? = nil
   
   var body: some View {
      VStack {
         Image(systemName: systemImage)
            .fitToFrame()
            .frame(width: 65, height: 65)
            .foregroundStyle(LinearGradient(colors: [Style.accentColor, Style.accentColor2], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.5, y: 0.6)))
//            .foregroundColor(Style.accentColor)
         
         Text(title)
            .font(.system(size: 31))
            .fontWeight(.bold)
         
         if let subtitle = subtitle {
            Spacer().frame(height: 10)
            Text(subtitle)
               .font(.callout)
               .foregroundColor(Color.secondaryLabel)
               .multilineTextAlignment(.center)
         }
         
         Spacer()
            .frame(height: 20)
      }
      .padding(.horizontal, 15)
   }
}

struct HabitCreationHeader_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         HabitCreationHeader(systemImage: "square.and.pencil", title: "Create New Habit", subtitle: "The lazy brown fox jumped over the moon, but why did the fox jump over the moon if it was lazy?")
      }
   }
}
