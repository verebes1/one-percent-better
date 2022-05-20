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
    
    static let context = CoreDataManager.shared.persistentContainer.viewContext
    static let habit = Habit(context: context, name: "Test")
    
    static var previews: some View {
        return ProgressView(habit: habit)
    }
}
