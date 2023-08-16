//
//  EveryXDays.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/10/23.
//

import SwiftUI

struct EveryXDays: View {
   
   @Binding var times: Int
   @Binding var everyXDays: Int
   
   var color: Color = Style.accentColor
   
   var body: some View {
      HStack(spacing: 7) {
         Menu {
            ForEach(1 ..< 11) { i in
               MenuItemWithCheckmark(value: i,
                                     selection: $times)
            }
         } label: {
            CapsuleMenuButton(text: String(times),
                              color: color,
                              fontSize: 15)
         }
         
         HStack(spacing: 0) {
            AnimatedPlural(text: "time", value: times)
            Text(" every")
         }
         
         Menu {
            ForEach(1 ..< 11) { i in
               MenuItemWithCheckmark(value: i,
                                     selection: $everyXDays)
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
   @State private var times = 1
   @State private var everyXDays = 2
   var body: some View {
      Background {
         EveryXDays(times: $times, everyXDays: $everyXDays)
      }
   }
}

struct EveryXDays_Previews: PreviewProvider {
   static var previews: some View {
      EveryXDaysPreviewer()
   }
}
