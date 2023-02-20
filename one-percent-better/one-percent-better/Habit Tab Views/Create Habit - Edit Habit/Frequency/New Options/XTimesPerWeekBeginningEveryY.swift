//
//  XTimesPerWeekBeginningEveryY.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct XTimesPerWeekBeginningEveryY: View {
   
   @Binding var timesPerWeek: Int
   @Binding var beginningDay: Weekday
   var color: Color = Style.accentColor
   
   var body: some View {
      VStack {
         HStack(spacing: 7) {
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
               AnimatedPlural(text: "time", value: timesPerWeek)
               Text(" per week")
            }
         }
         .animation(.easeInOut, value: timesPerWeek)
         
         HStack(spacing: 7) {
            Text("beginning every")
            Menu {
               MenuItemWithCheckmark(value: .saturday,
                                     selection: $beginningDay)
               
               MenuItemWithCheckmark(value: .friday,
                                     selection: $beginningDay)

               MenuItemWithCheckmark(value: .thursday,
                                     selection: $beginningDay)

               MenuItemWithCheckmark(value: .wednesday,
                                     selection: $beginningDay)

               MenuItemWithCheckmark(value: .tuesday,
                                     selection: $beginningDay)

               MenuItemWithCheckmark(value: .monday,
                                     selection: $beginningDay)

               MenuItemWithCheckmark(value: .sunday,
                                     selection: $beginningDay)
            } label: {
               CapsuleMenuButton(text: "\(beginningDay)",
                                         color: color,
                                         fontSize: 15)
            }
            Text("at midnight")
         }
         .animation(.easeInOut, value: beginningDay)
      }
      .padding(10)
   }
}

struct XTimesPerWeekBeginningEveryYPreviewer: View {
   
   @State private var timesPerWeek = 1
   @State private var beginningDay: Weekday = .sunday
   
   var body: some View {
      Background {
         XTimesPerWeekBeginningEveryY(timesPerWeek: $timesPerWeek, beginningDay: $beginningDay)
      }
   }
}

struct XTimesPerWeekBeginningEveryY_Previews: PreviewProvider {
   static var previews: some View {
      XTimesPerWeekBeginningEveryYPreviewer()
   }
}
