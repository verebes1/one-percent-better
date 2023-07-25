//
//  ImprovementGraphCardView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 12/4/22.
//

import SwiftUI

struct ImprovementGraphCardView: View {
   
   var it: ImprovementTracker
   
   var body: some View {
      CardView {
         VStack(spacing: 0) {
            CardTitleWithRightDetail("Improvement Score") {
               EmptyView()
            }
//            Text(String(describing: it.scores))
            if it.habit.daysCompleted.isEmpty {
               Text("A score which gets 1% larger every time you do your habit, and 0.5% smaller when you don't.")
                  .font(.system(size: 15))
                  .foregroundColor(.secondaryLabel)
                  .padding(15)
            } else {
               NewImprovementGraph(it: it)
                  .frame(height: 200)
                  .padding()
            }
         }
      }
   }
}

struct ImprovementGraphCardView_Previews: PreviewProvider {
   
   static let h0id = UUID()
   
   static func progressData() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming", id: ImprovementGraphCardView_Previews.h0id)
      h1?.updateStartDate(to: day2)
//      h1?.markCompleted(on: day0)
//      h1?.markCompleted(on: day1)
//      h1?.markCompleted(on: day2)
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      let habit = progressData()
      ImprovementGraphCardView(it: habit.improvementTracker!)
         .environment(\.managedObjectContext, CoreDataManager.previews.mainContext)
   }
}
