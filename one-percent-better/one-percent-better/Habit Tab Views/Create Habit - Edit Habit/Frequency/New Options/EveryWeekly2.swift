//
//  EveryWeekly2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/30/22.
//

import SwiftUI

struct EveryWeekly2: View {
   @State private var timesPerDay = 1
   
   var color: Color = Style.accentColor
   
   var isPlural: Binding<Bool> {
      Binding {
         timesPerDay > 1
      } set: { _, _ in
         // do nothing
      }
   }
   
   var body: some View {
      CardView {
         VStack {
            HStack(spacing: 0) {
               Menu {
                  Button("1", action: { timesPerDay = 1 })
                  Button("2", action: { timesPerDay = 2 })
                  Button("3", action: { timesPerDay = 3 })
                  Menu {
                     Button("4", action: { timesPerDay = 4 })
                     Button("5", action: { timesPerDay = 5 })
                     Button("6", action: { timesPerDay = 6 })
                     Button("7", action: { timesPerDay = 7 })
                     Button("8", action: { timesPerDay = 8 })
                     Button("9", action: { timesPerDay = 9 })
                     Button("10", action: { timesPerDay = 10 })
                  } label: {
                     Button("More...", action: {})
                  }
               } label: {
                  RoundedDropDownMenuButton(text: "\(timesPerDay)",
                                            color: color,
                                            fontSize: 15)
                  
               }
               
               HStack(spacing: 0) {
                  Text(" ")
                  AnimatedTimesText(plural: isPlural)
                  Text(" per week,")
               }
            }
            
            HStack(spacing: 0) {
               Text("resets every ")
               Menu {
                  Button("Monday", action: {  })
                  Button("Tuesday", action: {  })
                  Button("Wednesday", action: {  })
               } label: {
                  RoundedDropDownMenuButton(text: "Monday",
                                            color: color,
                                            fontSize: 15)
               }
               Text(" at midnight.")
            }
         }
         .animation(.easeInOut(duration: 0.3), value: timesPerDay > 1)
         .padding(10)
      }
   }
}

struct EveryWeekly2_Previews: PreviewProvider {
   static var previews: some View {
      Background {
         EveryWeekly2()
      }
   }
}
