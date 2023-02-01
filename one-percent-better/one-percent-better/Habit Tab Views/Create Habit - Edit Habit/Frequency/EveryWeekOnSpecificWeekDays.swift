//
//  EveryWeekOnSpecificWeekDays.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import SwiftUI


struct EveryWeekOnSpecificWeekDays: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @Binding var selectedWeekdays: [Int]
   
   var body: some View {
      VStack {
         Text("Every week on")
         HStack(spacing: 3) {
            ForEach(0 ..< 7) { i in
               WeekDayButton(i: i, selectedWeekdays: $selectedWeekdays)
            }
         }
         .padding(.horizontal, 25)
      }
      .padding(.vertical, 10)
   }
}

struct WeekDayButton: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   let i: Int
   @Binding var selectedWeekdays: [Int]
   let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
   
   func updateSelection(_ i: Int) {
      if selectedWeekdays.count == 1 && i == selectedWeekdays[0] {
         return
      }
      if let index = selectedWeekdays.firstIndex(of: i) {
         selectedWeekdays.remove(at: index)
      } else {
         selectedWeekdays.append(i)
      }
      selectedWeekdays = selectedWeekdays.sorted()
   }
   
   private var textColor: Color {
      colorScheme == .light ? .black : .white
   }
   
   private var selectedTextColor: Color {
      colorScheme == .light ? .white : .black
   }
   
   var body: some View {
      Button {
         withAnimation(.easeInOut(duration: 0.15)) {
            updateSelection(i)
         }
      } label : {
         let isSelected = selectedWeekdays.contains(i)
         Text(weekdays[i])
            .font(.system(size: 15))
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.vertical, 5)
            .frame(width: 40)
            .foregroundColor(isSelected ? selectedTextColor : textColor)
            .background(isSelected ? Style.accentColor : .grayButton)
            .clipShape(Capsule())
      }
   }
}

struct EveryWeekOnSpecificWeekDaysPreviews: View {
   @State var selectedWeekdays: [Int] = [1,2]
   @StateObject var vm = FrequencySelectionModel(selection: .daysInTheWeek([0, 2, 4]))
   
   var body: some View {
      Background {
         CardView {
            EveryWeekOnSpecificWeekDays(selectedWeekdays: $selectedWeekdays)
               .environmentObject(vm)
         }
      }
   }
}


struct EveryWeekOnSpecificWeekDays_Previews: PreviewProvider {
   static var previews: some View {
      EveryWeekOnSpecificWeekDaysPreviews()
   }
}


