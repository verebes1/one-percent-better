//
//  EveryXDays.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/10/23.
//

import SwiftUI

struct EveryXDays: View {
   
   @Binding var everyXDays: Int
   
   var body: some View {
      HStack(spacing: 7) {
         Text("Once every")
         Menu {
            MenuItemWithCheckmark(value: 2,
                                  selection: $everyXDays)
            MenuItemWithCheckmark(value: 3,
                                  selection: $everyXDays)
            MenuItemWithCheckmark(value: 4,
                                  selection: $everyXDays)
            MenuItemWithCheckmark(value: 5,
                                  selection: $everyXDays)
            Menu {
               MenuItemWithCheckmark(value: 6,
                                     selection: $everyXDays)
               MenuItemWithCheckmark(value: 7,
                                     selection: $everyXDays)
               MenuItemWithCheckmark(value: 8,
                                     selection: $everyXDays)
               MenuItemWithCheckmark(value: 9,
                                     selection: $everyXDays)
               MenuItemWithCheckmark(value: 10,
                                     selection: $everyXDays)
            } label: {
               Button("More...", action: {})
            }
         } label: {
            CapsuleMenuButton(text: String(everyXDays),
                                      color: Style.accentColor,
                                      fontSize: 15)
         }
         
         Text("days")
      }
      .animation(.easeInOut(duration: 0.3), value: everyXDays)
      .padding(10)
   }
}

struct EveryXDaysPreviewer: View {
   @State private var everyXDays = 2
   var body: some View {
      Background {
         EveryXDays(everyXDays: $everyXDays)
      }
   }
}

struct EveryXDays_Previews: PreviewProvider {
   static var previews: some View {
      EveryXDaysPreviewer()
   }
}
