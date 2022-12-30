//
//  EveryWeekly.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/27/22.
//

import SwiftUI


struct EveryWeekly: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @Binding var selectedWeekdays: [Int]
   
   var body: some View {
      VStack(spacing: 15) {
         Text("Every week on")
         HStack(spacing: 3) {
            ForEach(0 ..< 7) { i in
               WeekDayButton(i: i, selectedWeekdays: $selectedWeekdays)
            }
         }
         .padding(.horizontal, 25)
      }
      .padding(.vertical, 15)
   }
}

struct WeekDayButton: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   let i: Int
   @Binding var selectedWeekdays: [Int]
   let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
   
   private var selectedBackground: Color {
      colorScheme == .light ? Style.accentColor : Style.accentColor2
   }
   
   private var backgroundColor: Color {
      colorScheme == .light ?
      Color(#colorLiteral(red: 0.9310173988, green: 0.9355356693, blue: 0.935390532, alpha: 1))
      :
      Color(#colorLiteral(red: 0.1921563745, green: 0.1921573281, blue: 0.2135840654, alpha: 1))
      
   }
   private var selectedTextColor: Color {
      colorScheme == .light ?
      Color(#colorLiteral(red: 0.9061154127, green: 0.9810385108, blue: 1, alpha: 1))
      :
         .black
   }
   
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
      vm.selection = .daysInTheWeek(selectedWeekdays)
   }
   
   private var textColor: Color {
      colorScheme == .light ? .black : .white
   }
   
   var body: some View {
      Button {
         withAnimation(.easeInOut(duration: 0.2)) {
            updateSelection(i)
         }
      } label : {
         ZStack {
            let isSelected = selectedWeekdays.contains(i)
            RoundedRectangle(cornerRadius: 7)
               .foregroundColor(isSelected ? selectedBackground : backgroundColor)
            
            Text(weekdays[i])
               .fontWeight(isSelected ? .semibold : .regular)
               .foregroundColor(isSelected ? selectedTextColor : textColor)
         }
      }
      .frame(height: 32)
   }
}

struct EveryWeeklyPreviews: View {
   @State var selectedWeekdays: [Int] = [1,2]
   @StateObject var vm = FrequencySelectionModel(selection: .daysInTheWeek([0, 2, 4]))
   
   var body: some View {
      Background {
         CardView {
            EveryWeekly(selectedWeekdays: $selectedWeekdays)
               .environmentObject(vm)
         }
      }
   }
}


struct EveryWeekly_Previews: PreviewProvider {
   static var previews: some View {
      EveryWeeklyPreviews()
   }
}


