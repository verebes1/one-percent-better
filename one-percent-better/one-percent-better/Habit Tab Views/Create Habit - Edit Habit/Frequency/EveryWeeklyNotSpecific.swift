//
//  EveryWeeklyNotSpecific.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/29/22.
//

import SwiftUI

struct EveryWeeklyNotSpecific: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @Binding var timesPerDay: Int
   
   @Binding var selectedWeekdays: [Weekday]
   
   let tpdRange = 1 ... 100
   
   private let backgroundColor = Color(#colorLiteral(red: 0.9061154127, green: 0.9810385108, blue: 1, alpha: 1))
   
   var body: some View {
      VStack(spacing: 18) {
         HStack(spacing: 20) {
            
            MinusStepper(value: $timesPerDay, range: 1 ... 100) { val in
               self.vm.selection = .timesPerDay(val)
            }
            .frame(width: 50)
            .frame(height: 32)
            
            VStack {
               ZStack {
                  
                  RoundedRectangle(cornerRadius: 10)
                     .foregroundColor(colorScheme == .light ? Style.accentColor : Style.accentColor2)
                  
                  Text("\(timesPerDay)")
                     .font(.title3)
                     .fontWeight(.semibold)
                     .foregroundColor(colorScheme == .light ? backgroundColor : .black)
               }
               .frame(width: 50)
               .frame(height: 32)
            }
            
            PlusStepper(value: $timesPerDay, range: 1 ... 20) { val in
               self.vm.selection = .timesPerDay(val)
            }
            .frame(width: 50)
            .frame(height: 32)
         }
         
         HStack(spacing: 0) {
            Text(" per week, resets on")
               .animation(.easeInOut(duration: 0.3), value: timesPerDay > 1)
         }
         
         HStack(spacing: 3) {
            ForEach(0 ..< 7) { i in
               WeekDayButton(i: i, selectedWeekdays: $selectedWeekdays)
            }
         }
         .padding(.horizontal, 25)
         
         Text("every week at midnight.")
      }
      .padding(.vertical, 15)
   }
}



struct EveryWeeklyNotSpecificPreview: View {
   @State private var timesPerDay = 1
   @State var selectedWeekdays: [Weekday] = [.monday, .tuesday]
   @StateObject var vm = FrequencySelectionModel(selection: .specificWeekdays([.sunday, .tuesday, .thursday]))
   
   var body: some View {
      Background {
         CardView {
            EveryWeeklyNotSpecific(timesPerDay: $timesPerDay, selectedWeekdays: $selectedWeekdays)
               .environmentObject(vm)
         }
      }
   }
}

struct EveryWeeklyNotSpecific_Previews: PreviewProvider {
   static var previews: some View {
      EveryWeeklyNotSpecificPreview()
   }
}
