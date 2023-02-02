//
//  SelectableCard2.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 1/9/23.
//

import SwiftUI

struct SelectableCard2<Content>: View where Content: View {
   
   @Environment(\.colorScheme) var scheme
   
   var isSelected: Bool
   
   let content: () -> Content
   
   var onSelection: () -> Void = {}
   
   @State private var scale = 1.0
   
   var checkmarkImageName: String {
      isSelected ? "checkmark.circle.fill" : "circle"
   }
   
   let cornerRadius: CGFloat = 17
   
   let cardColor = Color( #colorLiteral(red: 0.1725487709, green: 0.1725491583, blue: 0.1811430752, alpha: 1) )
   
   var body: some View {
      CardView(cornerRadius: cornerRadius) {
         content()
      }
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
//      .simultaneousGesture(
//         DragGesture(minimumDistance: 0)
//            .onChanged({ _ in
//               if !isSelected {
//                  withAnimation(.easeInOut(duration: 0.15)) {
//                     scale = 0.95
//                  }
//               }
//            })
//            .onEnded({ _ in
//               print("TOUCH ENDED!!")
//               withAnimation(.easeInOut(duration: 0.15)) {
//                  scale = 1
//                  onSelection()
//               }
//            })
//      )
//      .border(.black)
//      .fontWeight(isSelected ? .medium : .regular)
   }
}

struct SelectableCard2Wrapper<Content>: View where Content: View {
   
   @Binding var selection: HabitFrequencyTest
   let type: HabitFrequencyTest
   let content: () -> Content
   var onSelection: () -> Void = {}
   
   func isSameType(selection: HabitFrequencyTest, type: HabitFrequencyTest) -> Bool {
      switch type {
      case .timesPerDay(_):
         if case .timesPerDay(_) = selection {
            return true
         }
      case.daysInTheWeek(_):
         if case .daysInTheWeek(_) = selection {
            return true
         }
      case .timesPerWeek(_, _):
         if case .timesPerWeek(_, _) = selection {
            return true
         }
      case .everyXDays(_):
         if case .everyXDays(_) = selection {
            return true
         }
      }
      return false
   }
   
   var body: some View {
      SelectableCard2(isSelected: isSameType(selection: selection, type: type)) {
         content()
            .padding(.vertical, 5)
      } onSelection: {
         onSelection()
      }
      .contentShape(Rectangle())
   }
}

struct SelectableCard2_Previewer: View {
   
   @State private var selection: HabitFrequencyTest = .timesPerDay(2)
   
   @State private var tpd = 2
   
   var body: some View {
      Background {
         VStack {
            SelectableCard2Wrapper(selection: $selection, type: .timesPerDay(2)) {
               EveryDayXTimesPerDay(timesPerDay: $tpd)
            }
            
            SelectableCard2Wrapper(selection: $selection, type: .daysInTheWeek([1,2,3])) {
               XTimesPerWeekBeginningEveryY()
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
