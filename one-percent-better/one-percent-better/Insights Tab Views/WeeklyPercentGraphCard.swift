//
//  WeeklyPercentGraphCard.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/7/22.
//

import SwiftUI
import Charts

struct WeeklyPercentGraphCard: View {
   
   @StateObject var vm = HeaderWeekViewModel()
   
   func dailyPercent() -> [GraphPoint] {
      var r = [GraphPoint]()
      var curDay = vm.earliestStartDate
      
      var dates = [Date]()
      var values = [Double]()
      
      while !Cal.isDateInTomorrow(curDay) {
         let percent = vm.percent(on: curDay) * 100
//         r.append(GraphPoint(date: curDay, value: percent))
         dates.append(curDay)
         values.append(percent)
         curDay = Cal.add(days: 1, to: curDay)
      }
      
      values = movingAverage(points: values)
      
      for i in 0 ..< dates.count {
         r.append(GraphPoint(date: dates[i], value: values[i]))
      }
      
      return r
   }
   
   // Define a function that calculates the moving average of a given array of points with a period of 5
   func movingAverage(points: [Double]) -> [Double] {
      // Create an array to store the moving average values
      var movingAverage: [Double] = []
      
      let period = Int(sliderValue)
      
      // Calculate the moving average for each point in the array
      for i in 0..<points.count {
         // Calculate the sum of the 5 points leading up to the current point
         
         let lowerRange = max(0, i - period)
         let upperRange = max(1, i)
         let sum = points[lowerRange ..< upperRange].reduce(0, +)
         
         
         let numPoints = i - max(0, i - period)
         let div = max(1, numPoints)
         
         // Calculate the moving average by dividing the sum by the number of points (5)
         let average = sum / Double(div)
         
         // Add the moving average value to the array
         movingAverage.append(average)
      }
      
      // Return the array of moving average values
      return movingAverage
   }
   
   @State private var data: [GraphPoint] = []
   @State private var sliderValue = 3.0
   
   var body: some View {
      let _ = Self._printChanges()
      CardView {
         VStack(alignment: .leading) {
            CardTitleWithRightDetail("Daily Percent Completed") {
               EmptyView()
            }
            
            Text("\(Int(sliderValue)) day moving average")
               .font(.system(size: 15))
               .foregroundColor(.secondaryLabel)
               .padding(.horizontal, 20)
            
            Chart {
               ForEach(data, id: \.date) { item in
                  LineMark(
                     x: .value("Date", item.date),
                     y: .value("Percent", item.value)
                  )
                  .interpolationMethod(.monotone)
               }
            }
            .chartYScale(domain: 0 ... 100)
            .frame(height: 250)
            .padding()
            
            Slider(value: $sliderValue, in: 1 ... 30, step: 1, label: {
               Text("Moving average")
            }, minimumValueLabel: {
               Text("1")
                  .foregroundColor(.secondaryLabel)
            }, maximumValueLabel: {
               Text("30")
                  .foregroundColor(.secondaryLabel)
            }, onEditingChanged: { isEditing in
               print(isEditing)
            })
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
         }
         .task {
            data = dailyPercent()
         }
         .onChange(of: sliderValue) { newValue in
            data = dailyPercent()
         }
      }
   }
}

struct WeeklyPercentGraphCard_Previews: PreviewProvider {
   static let id1 = UUID()
   static let id2 = UUID()
   static let id3 = UUID()
   static let id4 = UUID()
   
   static func data() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let h1 = try? Habit(context: context, name: "Swimming", id: id1)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -3, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: 0, to: Date())!)
      h1?.markCompleted(on: Cal.date(byAdding: .day, value: -1, to: Date())!)
      h1?.markCompleted(on: Cal.add(days: -10))
      h1?.markCompleted(on: Cal.add(days: -11))
      h1?.markCompleted(on: Cal.add(days: -12))
      
      let h2 = try? Habit(context: context, name: "Basketball (MWF)", id: id2)
      h2?.changeFrequency(to: .specificWeekdays([.monday, .wednesday, .friday, .saturday]))
      h2?.markCompleted(on: Date())
      h2?.markCompleted(on: Cal.add(days: -1))
      
      let h3 = try? Habit(context: context, name: "Timed Habit", id: id3)
      
      if let h3 = h3 {
         let _ = TimeTracker(context: context, habit: h3, goalTime: 10)
      }
      h3?.markCompleted(on: Date())
      
      let h4 = try? Habit(context: context, name: "Twice A Day", frequency: .timesPerDay(2), id: id4)
      h4?.markCompleted(on: Cal.add(days: -3))
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      let _ = data()
      let moc = CoreDataManager.previews.mainContext
      let vm = HeaderWeekViewModel(moc)
      
      Background {
         WeeklyPercentGraphCard()
            .environmentObject(vm)
      }
   }
}
