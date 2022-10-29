//
//  AnimatedHabitCreationHeader.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/29/22.
//

import SwiftUI

struct AnimatedHabitCreationHeader: View {
   
   @Binding var animateBell: Bool
   let title: String
   var subtitle: String? = nil
   
   var body: some View {
      VStack {
         AnimatedBellWrapper(animateBell: $animateBell)
            .frame(width: 65, height: 65)
            .foregroundColor(Style.accentColor)
//            .animate
         
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
//      .border(.black)
   }
}

struct AnimatedHabitCreationHeader_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         AnimatedHabitCreationHeader(animateBell: .constant(false), title: "Create New Habit", subtitle: "The lazy brown fox jumped over the moon, but why did the fox jump over the moon if it was lazy?")
      }
   }
}
