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
         VStack {
            CardTitleWithRightDetail("Improvement Score") {
               EmptyView()
            }
            NewImprovementGraph(it: it)
               .frame(height: 200)
               .padding()
         }
      }
   }
}

struct ImprovementGraphCardView_Previews: PreviewProvider {
   
   static func progressData() -> Habit {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Swimming")
      h1?.markCompleted(on: day0)
      h1?.markCompleted(on: day1)
      h1?.markCompleted(on: day2)
      
      let habits = Habit.habits(from: context)
      return habits.first!
   }
   
   static var previews: some View {
      let habit = progressData()
      ImprovementGraphCardView(it: habit.improvementTracker!)
   }
}
