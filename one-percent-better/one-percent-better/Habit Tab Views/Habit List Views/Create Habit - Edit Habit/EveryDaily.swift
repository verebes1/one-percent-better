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
   
   var body: some View {
      VStack {
         HStack {
            ZStack {
               
               RoundedRectangle(cornerRadius: 10)
                  .foregroundColor(colorScheme == .light ? backgroundColor : Style.accentColor)
               
               Text("\(timesPerDay)")
                  .font(.title3)
                  .fontWeight(.semibold)
                  .foregroundColor(colorScheme == .light ? Style.accentColor : backgroundColor)
            }
            .frame(width: 50)
            .frame(height: 32)
            
            
            Text("time\(timesPerDay == 1 ? " " : "s ")a day")
            Spacer()
            
            MyStepper(value: $timesPerDay, range: 1 ... 100) { val in
               self.vm.selection = .timesPerDay(val)
            } onDecrement: { val in
               self.vm.selection = .timesPerDay(val)
            }
         }
      }
      .padding()
   }
}

struct EveryDailyPreviewContainer: View {
   
   @State private var timesPerDay = 1
   
   var body: some View {
      Background {
         CardView {
            EveryDaily(timesPerDay: $timesPerDay)
         }
      }
   }
}

struct EveryDaily_Previews: PreviewProvider {
   
   static var previews: some View {
      EveryDailyPreviewContainer()
   }
}
