//
//  EveryXDays.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/10/23.
//

import SwiftUI

struct EveryXDays: View {
   @State private var timesPerDay = "1"
   
   var color: Color = Style.accentColor
   
   var isPlural: Binding<Int> {
      Binding {
         Int(timesPerDay) ?? 0
      } set: { _ in }
   }
   
   var body: some View {
      HStack(spacing: 7) {
         Text("Every")
         Menu {
            MenuItemWithCheckmark(text: "1",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(text: "2",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(text: "3",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(text: "4",
                                  selection: $timesPerDay)
            MenuItemWithCheckmark(text: "5",
                                  selection: $timesPerDay)
            Menu {
               MenuItemWithCheckmark(text: "6",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(text: "7",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(text: "8",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(text: "9",
                                     selection: $timesPerDay)
               MenuItemWithCheckmark(text: "10",
                                     selection: $timesPerDay)
            } label: {
               Button("More...", action: {})
            }
         } label: {
            RoundedDropDownMenuButton(text: $timesPerDay,
                                      color: color,
                                      fontSize: 15)
         }
         
         HStack(spacing: 0) {
            // TODO: fixme
//            AnimatedTimesText(plural: isPlural)
            Text(" per day")
         }
      }
      .animation(.easeInOut(duration: 0.3), value: timesPerDay)
      .padding(10)
   }
}

struct EveryXDays_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         EveryXDays()
      }
   }
}
