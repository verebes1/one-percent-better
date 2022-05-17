//
//  HabitRowView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData

struct HabitsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            
            List(habits, id: \.self.name) { habit in
                HabitRow(habit: habit)
            }
            
//            Button("Add random habit") {
//                let habitNames = ["Ginny", "Harry", "Hermione", "Luna", "Ron"]
//                let name = habitNames.randomElement()!
//                let _ = try? Habit(context: moc, name: name)
//                try? moc.save()
//            }
            
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        print("Edit tapped!")
                    }
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HabitsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let _ = try? Habit(context: context, name: "Basketball")
        return HabitsView()
            .environment(\.managedObjectContext, context)
    }
}

struct HabitRow: View {
    
    @State var habit: Habit
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func ringButtonCallback(completed: Bool) {
        completed ? habit.markCompleted(on: Date()) : habit.markNotCompleted(on: Date())
    }
    
    var body: some View {
        HStack {
            VStack {
                RingView(percent: 0,
                         size: 28,
                         buttonCallback: ringButtonCallback)
            }
            VStack(alignment: .leading) {
                
                Text(habit.name)
                    .font(.system(size: 16))
                
                Text(habit.streakLabel)
                    .font(.system(size: 11))
                    .foregroundColor(habit.streakLabelColor)
//                    .onReceive(timer, perform: { date in
//                        timerLabel = "\(date)"
//                        secondaryLabel = showTimer ? timerLabel : streakLabel
//                    })
            }
            Spacer()
            
            // TODO replace with navigation link
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 7)
                .foregroundColor(Color.gray)
        }
    }
}
