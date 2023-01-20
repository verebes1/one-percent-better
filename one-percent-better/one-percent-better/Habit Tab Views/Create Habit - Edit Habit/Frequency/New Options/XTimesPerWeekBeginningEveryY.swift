//
//  XTimesPerWeekBeginningEveryY.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct XTimesPerWeekBeginningEveryY: View {
   
   @State private var timesPerWeek = 1
   @State private var beginningDay = "Sunday"
   var color: Color = Style.accentColor
   
   var body: some View {
      VStack {
         HStack(spacing: 0) {
            Menu {
               
               MenuItemWithCheckmark(value: 1,
                                        selection: $timesPerWeek)
               MenuItemWithCheckmark(value: 2,
                                        selection: $timesPerWeek)
               MenuItemWithCheckmark(value: 3,
                                        selection: $timesPerWeek)
               MenuItemWithCheckmark(value: 4,
                                        selection: $timesPerWeek)
               MenuItemWithCheckmark(value: 5,
                                        selection: $timesPerWeek)
               
               Menu {
                  MenuItemWithCheckmark(value: 6,
                                           selection: $timesPerWeek)
                  MenuItemWithCheckmark(value: 7,
                                           selection: $timesPerWeek)
                  MenuItemWithCheckmark(value: 8,
                                           selection: $timesPerWeek)
                  MenuItemWithCheckmark(value: 9,
                                           selection: $timesPerWeek)
                  MenuItemWithCheckmark(value: 10,
                                           selection: $timesPerWeek)
               } label: {
                  Button("More...", action: {})
               }
            } label: {
               CapsuleMenuButton(text: String(timesPerWeek),
                                         color: color,
                                         fontSize: 15)
            }
            
            HStack(spacing: 0) {
               Text(" ")
               AnimatedPlural(text: "time", value: timesPerWeek)
               Text(" per week")
            }
         }
         .animation(.easeInOut, value: timesPerWeek)
         
         HStack(spacing: 0) {
            Text("beginning every ")
            Menu {
               MenuItemWithCheckmark(value: "Saturday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: "Friday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: "Thursday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: "Wednesday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: "Tuesday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: "Monday",
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: "Sunday",
                                     selection: $beginningDay)
            } label: {
               CapsuleMenuButton(text: beginningDay,
                                         color: color,
                                         fontSize: 15)
            }
         }
         .animation(.easeInOut, value: beginningDay)
      }
      .padding(10)
   }
}

struct XTimesPerWeekBeginningEveryY_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         XTimesPerWeekBeginningEveryY()
      }
   }
}
