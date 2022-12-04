//
//  NewImprovementGraph.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 11/13/22.
//

import SwiftUI
import Charts

struct NewImprovementGraph: View {
   
   var it: ImprovementTracker
   
   struct GraphPoint {
       var date: Date
       var value: Double
   }
   
   var improvementArr: [GraphPoint] {
      var result = [GraphPoint]()
      for i in 0 ..< it.dates.count {
         result.append(GraphPoint(date: it.dates[i], value: it.scores[i]))
      }
      return result
   }
   
//   @State var position: ChartPosition?
   
   var body: some View {
      Chart {
         ForEach(improvementArr, id: \.date) { item in
                 LineMark(
                     x: .value("Date", item.date),
                     y: .value("Profit B", item.value),
                     series: .value("Company", "B")
                 )
//                 .symbol(.circle)
//                 .symbolSize(14)
                 .interpolationMethod(.catmullRom)
//                 .interpolationMethod(.cardinal)
//                 .interpolationMethod(.linear)
                 .foregroundStyle(Color.mint)
             }
      }
//      .chartOverlay { proxy in
//         GeometryReader { geometry in
//            Rectangle().fill(.clear).contentShape(Rectangle())
//               .gesture(DragGesture(minimumDistance: 0).onChanged { value in updateCursorPosition(at: value.location, geometry: geometry, proxy: proxy) })
//         }
//      }
//      .chartYScale(domain: vm.improvementRange)
//      .chartXAxis(.hidden)
//      .chartYAxis(.hidden)
//      .frame(width: 300, height: 200)
      
   }
   
   func updateCursorPosition(at: CGPoint, geometry: GeometryProxy, proxy: ChartProxy) {
      
      // Convert the gesture location to the coordinate space of the plot area.
      let origin = geometry[proxy.plotAreaFrame].origin
      let location = CGPoint(
         x: at.x - origin.x,
         y: at.y - origin.y
      )
      // Get the x (date) and y (price) value from the location.
      let (date, price) = proxy.value(at: location, as: (Date, Double).self)!
      print("Location: \(date), \(price)")
      
//      let origin = geometry[proxy.plotAreaFrame].origin
//      let datePos = proxy.value(atX: at.x - origin.x, as: Date.self)
//      let firstGreater = improvementArr.lastIndex(where: { $0.date.startOfDay() < datePos!.startOfDay() })
//      if let index = firstGreater {
//         let date = improvementArr[index].date.startOfDay()
//         let value = improvementArr[index].value
//         position = GraphPoint(date: date, value: value)
//      }
   }
}

struct NewImprovementGraph_Previews: PreviewProvider {
   static func progressData() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day0)
      h1?.markCompleted(on: day1)
      h1?.markCompleted(on: day2)
      
      if let h1 = h1 {
         let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
         t1.add(date: day0, value: "3")
         t1.add(date: day1, value: "2")
         t1.add(date: day2, value: "1")
         
         let t2 = ImageTracker(context: context, habit: h1, name: "Progress Pics")
         let patioBefore = UIImage(named: "patio-before")!
         t2.add(date: day0, value: patioBefore)
      }
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      let habit = progressData()
      return(
         NavigationView {
            NewImprovementGraph(it: habit.improvementTracker!)
               .frame(width: 300, height: 150)
//               .environmentObject(habit)
//               .environmentObject(HabitTabNavPath())
         }
      )
   }
}
