//
//  EveryDaily.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 9/26/22.
//

import SwiftUI

struct EveryDaily: View {
   
   @Environment(\.colorScheme) var colorScheme
   
   @EnvironmentObject var vm: FrequencySelectionModel
   
   @Binding var timesPerDay: Int
   let tpdRange = 1 ... 100
   
   private let backgroundColor = Color(#colorLiteral(red: 0.9061154127, green: 0.9810385108, blue: 1, alpha: 1))
   
   var isPlural: Binding<Bool> {
      Binding {
         timesPerDay > 1
      } set: { _, _ in
         // do nothing
      }
   }
   
   var body: some View {
      VStack {
         HStack(spacing: 20) {
            
            MinusStepper(value: $timesPerDay, range: 1 ... 100) { val in
               self.vm.selection = .timesPerDay(val)
            }
            .frame(width: 50)
            .frame(height: 42)
            
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
               
               AnimatedTimesText(plural: isPlural)
            }
            
            PlusStepper(value: $timesPerDay, range: 1 ... 100) { val in
               self.vm.selection = .timesPerDay(val)
            }
            .frame(width: 50)
            .frame(height: 42)
            
//            Spacer().frame(width: 50)
            
//            MyStepper(value: $timesPerDay, range: 1 ... 100) { val in
//               self.vm.selection = .timesPerDay(val)
//            } onDecrement: { val in
//               self.vm.selection = .timesPerDay(val)
//            }
         }
      }
      .padding(.vertical, 30)
   }
}

struct EveryDailyPreviewContainer: View {
   
   @StateObject var vm = FrequencySelectionModel(selection: .timesPerDay(2))
   @State private var timesPerDay = 1
   
   var body: some View {
      Background {
         CardView {
            EveryDaily(timesPerDay: $timesPerDay)
               .environmentObject(vm)
         }
      }
   }
}

struct EveryDaily_Previews: PreviewProvider {
   
   static var previews: some View {
      EveryDailyPreviewContainer()
   }
}
