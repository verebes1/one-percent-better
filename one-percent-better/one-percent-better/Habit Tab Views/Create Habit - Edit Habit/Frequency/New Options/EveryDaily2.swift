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
   
   var isPlural: Binding<Bool> {
         Binding {
            if let tpd = Int(timesPerDay), tpd > 1 {
               return true
            }
            return false
         } set: { _, _ in
            // do nothing
         }
      }
   
   var body: some View {
      HStack {
         Text("Every day,")
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
            AnimatedTimesText(plural: isPlural)
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
