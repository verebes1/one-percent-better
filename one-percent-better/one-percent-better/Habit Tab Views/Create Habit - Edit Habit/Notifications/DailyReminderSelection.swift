//
//  DailyReminderSelection.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/1/23.
//

import SwiftUI

struct DailyReminderSelection: View {
   
   @State private var timesPerDay = 1
   
   var color: Color = Style.accentColor
   
   var body: some View {
      HStack {
         
         HStack(spacing: 0) {
            AnimatedPlural(text: "time", value: timesPerDay)
            Text(" per week")
         }
      }
      .animation(.easeInOut(duration: 0.3), value: timesPerDay)
      .padding(10)
   }
}

struct DailyReminderSelection_Previews: PreviewProvider {
   static var previews: some View {
      DailyReminderSelection()
   }
}
