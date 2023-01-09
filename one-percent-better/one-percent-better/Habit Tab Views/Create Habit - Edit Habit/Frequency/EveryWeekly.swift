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
   
   var selectedBackground: Color = Style.accentColor
   
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
            .background(isSelected ? selectedBackground : backgroundColor)
            .clipShape(Capsule())
      }
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


