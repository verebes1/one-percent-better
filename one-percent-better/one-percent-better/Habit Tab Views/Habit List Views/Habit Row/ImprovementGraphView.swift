//
//  ImprovementGraphView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/7/22.
//

import SwiftUI
import Charts

extension HabitRowViewModel {
   struct GraphPoint {
       var date: Date
       var value: Double
   }
   
   var improvementArr: [GraphPoint] {
      var result = [GraphPoint]()
      
      for i in 0 ..< 5 {
         let day = Cal.date(byAdding: .day, value: -i, to: Date())!
//         let value = habit.im
      }
      return result
   }
   
//   let departmentBProfit: [GraphPoint] = [
//      ProfitOverTime(date: Date(), profit: 15),
//      ProfitOverTime(date: Cal.date(byAdding: .day, value: -1, to: Date())!, profit: 10),
//      ProfitOverTime(date: Cal.date(byAdding: .day, value: -2, to: Date())!, profit: 7),
//      ProfitOverTime(date: Cal.date(byAdding: .day, value: -3, to: Date())!, profit: 7)
//   ]
}

struct ImprovementGraphView: View {
   
//   var habit: Habit
   @EnvironmentObject var vm: HabitRowViewModel
   
   var body: some View {
      Chart {
         ForEach(vm.improvementArr, id: \.date) { item in
                 LineMark(
                     x: .value("Date", item.date),
                     y: .value("Profit B", item.value),
                     series: .value("Company", "B")
                 )
//                 .interpolationMethod(.catmullRom)
                 .foregroundStyle(.green)
             }
      }
//      .chartXAxis(.hidden)
//      .chartYAxis(.hidden)
//      .frame(width: 300, height: 200)
   }
}

struct ImprovementGraphView_Previews: PreviewProvider {
   static var previews: some View {
      ImprovementGraphView()
//         .border(.black)
   }
}
