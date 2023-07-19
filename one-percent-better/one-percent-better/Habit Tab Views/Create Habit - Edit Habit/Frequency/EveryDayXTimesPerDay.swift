//
//  EveryDayXTimesPerDay.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI
import Combine

struct EveryDayXTimesPerDay: View {
   
   @Binding var timesPerDay: Int
   
   var color: Color = Style.accentColor
   
   var body: some View {
      HStack {
         Text("Every day,")
         Menu {
            ForEach(1 ..< 11) { i in
               MenuItemWithCheckmark(value: i,
                                     selection: $timesPerDay)
            }
         } label: {
            CapsuleMenuButton(text: String(timesPerDay),
                              color: color,
                              fontSize: 15)
         }
         
         HStack(spacing: 0) {
            AnimatedPlural(text: "time", value: timesPerDay)
            Text(" per day")
         }
      }
      .animation(.easeInOut(duration: 0.3), value: timesPerDay)
      .padding(10)
   }
   
}

struct EveryDayXTimesPerDayPreviewer: View {
   @State private var tpd = 1
   var body: some View {
      Background {
         EveryDayXTimesPerDay(timesPerDay: $tpd)
      }
   }
}

struct EveryDayXTimesPerDay_Previews: PreviewProvider {
   static var previews: some View {
      EveryDayXTimesPerDayPreviewer()
   }
}
