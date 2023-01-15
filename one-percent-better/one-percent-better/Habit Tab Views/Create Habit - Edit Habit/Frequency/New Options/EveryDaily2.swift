//
//  EveryDaily2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct EveryDaily2: View {
   
   @State private var timesPerDay = "1"
   
   var color: Color = Style.accentColor
   
   var timesPerDayInt: Binding<Int> {
      Binding {
         if let tpd = Int(timesPerDay) {
            return tpd
         }
         return 0
      } set: { _, _ in
         // do nothing
      }
   }
   
   var body: some View {
      HStack {
         Text("Every day,")
         Menu {
            MenuItemWithCheckmark(value: "1",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(value: "2",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(value: "3",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(value: "4",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(value: "5",
                                  selection: $timesPerDay)
            Menu {
               MenuItemWithCheckmark(value: "6",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(value: "7",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(value: "8",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(value: "9",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(value: "10",
                                     selection: $timesPerDay)
            } label: {
               Button("More...", action: {})
            }
         } label: {
            CapsuleMenuButton(text: timesPerDay,
                                      color: color,
                                      fontSize: 15)
         }
         
         HStack(spacing: 0) {
            AnimatedPluralInt(text: "time", value: timesPerDayInt)
            Text(" per day")
         }
      }
      .animation(.easeInOut(duration: 0.3), value: timesPerDay)
      .padding(10)
   }
   
}

struct EveryDaily2_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         EveryDaily2()
      }
   }
}
