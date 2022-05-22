//
//  ProgressView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 5/18/22.
//

import SwiftUI
import CoreData

struct ProgressView: View {
    
    var habit: Habit
    
    var body: some View {
        ZStack {
            Background()
            
            VStack {
                
                HStack {
                    Text(habit.name)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    .font(.title)
                    Spacer()
                }
                .padding(.horizontal, 15)
                CalendarView()
                Text("Hello World")
                Spacer()
            }
        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        let habit = Habit(context: context, name: "Swimming")
        return ProgressView(habit: habit)
    }
}
