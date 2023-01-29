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
