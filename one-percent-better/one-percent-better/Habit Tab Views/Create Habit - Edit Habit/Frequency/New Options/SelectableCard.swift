//
//  SelectableCard2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct SelectableCard<Content>: View where Content: View {
   
   @Environment(\.colorScheme) var scheme
   
   var isSelected: Bool
   
   let content: () -> Content
   
   var onSelection: () -> Void = {}
   
   @State private var scale = 1.0
   
   var checkmarkImageName: String {
      isSelected ? "checkmark.circle.fill" : "circle"
   }
   
   let cornerRadius: CGFloat = 17
   
   var body: some View {
      CardView {
         content()
      }
      .contentShape(Rectangle())
      .overlay {
         ZStack {
            if isSelected {
               RoundedRectangle(cornerRadius: cornerRadius)
                  .stroke(Style.accentColor, lineWidth: 2)
                  .padding(.horizontal, 10)
            }
               
            VStack {
               HStack {
                  Spacer()
                  CheckmarkToggleButton(state: isSelected)
                     .padding(.trailing, 10)
                     .padding(10)
               }
               Spacer()
            }
         }
      }
      .simultaneousGesture(
         TapGesture()
            .onEnded { _ in
               onSelection()
            }
      )
//      .transition(.opacity)
//      .animation(.easeInOut(duration: 0.1), value: isSelected)
   }
}

struct SelectableFrequencyCard<Content>: View where Content: View {
   
   @Binding var selection: HabitFrequency
   let type: HabitFrequency
   let content: () -> Content
   var onSelection: () -> Void = {}
   
   func isSameType(selection: HabitFrequency, type: HabitFrequency) -> Bool {
      switch type {
      case .timesPerDay:
         if case .timesPerDay = selection {
            return true
         }
      case.daysInTheWeek:
         if case .daysInTheWeek = selection {
            return true
         }
      case .timesPerWeek:
         if case .timesPerWeek = selection {
            return true
         }
      }
      return false
   }
   
   var body: some View {
      SelectableCard(isSelected: isSameType(selection: selection, type: type)) {
         content()
            .padding(.vertical, 5)
      } onSelection: {
         onSelection()
      }
   }
}

struct SelectableCard2_Previewer: View {
   
   @State private var selection: HabitFrequency = .timesPerDay(2)
   
   @State private var tpd = 2
   
   @State private var tpw = 3
   @State private var resetDay: Weekday = .sunday
   
   var body: some View {
      Background {
         VStack {
            SelectableFrequencyCard(selection: $selection, type: .timesPerDay(2)) {
               EveryDayXTimesPerDay(timesPerDay: $tpd)
            } onSelection: {
               selection = .timesPerDay(2)
            }
            
            SelectableFrequencyCard(selection: $selection, type: .daysInTheWeek([.monday, .tuesday, .wednesday])) {
               XTimesPerWeekBeginningEveryY(timesPerWeek: $tpw, beginningDay: $resetDay)
            } onSelection: {
               selection = .daysInTheWeek([.monday, .tuesday])
            }
         }
      }
   }
}

struct SelectableCard2_Previews: PreviewProvider {
   static var previews: some View {
      SelectableCard2_Previewer()
   }
}
