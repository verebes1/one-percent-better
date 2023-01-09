//
//  EveryWeekly2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct EveryWeekly2: View {
   @State private var timesPerWeek = "1"
   @State private var beginningDay = "Sunday"
   
   var color: Color = Style.accentColor
   
   var isPlural: Binding<Bool> {
      Binding {
         if let tpw = Int(timesPerWeek), tpw > 1 {
            return true
         }
         return false
      } set: { _, _ in
         // do nothing
      }
   }
   
   var body: some View {
      VStack {
         HStack(spacing: 0) {
            Menu {
               MenuItemWithCheckmark(text: "1",
                                     selection: $timesPerWeek)
               MenuItemWithCheckmark(text: "2",
                                     selection: $timesPerWeek)
               MenuItemWithCheckmark(text: "3",
                                     selection: $timesPerWeek)
               MenuItemWithCheckmark(text: "4",
                                     selection: $timesPerWeek)
               MenuItemWithCheckmark(text: "5",
                                     selection: $timesPerWeek)
//               Menu {
//                  Button("6", action: { timesPerWeek = 6 })
//                  Button("7", action: { timesPerWeek = 7 })
//                  Button("8", action: { timesPerWeek = 8 })
//                  Button("9", action: { timesPerWeek = 9 })
//                  Button("10", action: { timesPerWeek = 10 })
//               } label: {
//                  Button("More...", action: {})
//               }
            } label: {
               RoundedDropDownMenuButton(text: $timesPerWeek,
                                         color: color,
                                         fontSize: 15)
            }
            
            HStack(spacing: 0) {
               Text(" ")
               AnimatedTimesText(plural: isPlural)
               Text(" per week,")
            }
         }
         .animation(.easeInOut, value: timesPerWeek)
//         .animation(.easeInOut(duration: 0.3), value: timesPerWeek > 1)
         
         HStack(spacing: 0) {
            Text("beginning ")
            Menu {
               MenuItemWithCheckmark(text: "Saturday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(text: "Friday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(text: "Thursday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(text: "Wednesday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(text: "Tuesday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(text: "Monday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(text: "Sunday",
                                     selection: $beginningDay)
            } label: {
               RoundedDropDownMenuButton(text: $beginningDay,
                                         color: color,
                                         fontSize: 15)
               
//               .animation(.easeInOut(duration: 10), value: beginningDay)
            }
            Text(" at midnight.")
         }
      }
      .padding(10)
   }
}

struct EveryWeekly2_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         EveryWeekly2()
      }
   }
}

struct MenuItemWithCheckmark: View {
   var text: String
   @Binding var selection: String

   var body: some View {
      Button {
         selection = text
      } label: {
         Label(text, systemImage: text == selection ? "checkmark" : "")
      }
   }
}
