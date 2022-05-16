//
//  HabitRowView.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 5/8/22.
//

import SwiftUI
import CoreData

struct HabitList: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var habits: FetchedResults<Habit>
    
    var body: some View {
        VStack {
            Text("Habits")
            List(0 ..< habits.count, id: \.self) { i in
                HabitRow(habitName: habits[i].name, streakLabel: "Test")
            }
            
            Button("Add random habit") {
                let habitNames = ["Ginny", "Harry", "Hermione", "Luna", "Ron"]
                
                let name = habitNames.randomElement()!
                let _ = try? Habit(context: moc, name: name)
                try? moc.save()
            }
        }
    }
}

struct HabitListView_Previews: PreviewProvider {
    
    static var previews: some View {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let _ = try? Habit(context: context, name: "Basketball")
        return HabitList()
            .environment(\.managedObjectContext, context)
    }
}

struct HabitRow: View {
    
    var habit: Habit?
    
    var habitName = "Habit Name"
    
    @State var secondaryLabel = ""
    @State var streakLabel = "Streak label"
    @State var timerLabel = "3:15"
    @State var showTimer = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func ringButtonCallback(state: Bool) {
        showTimer = state
    }
    
    var body: some View {
        HStack {
            VStack {
                RingView(percent: 0,
                         size: 28,
                         buttonCallback: ringButtonCallback)
            }
            VStack(alignment: .leading) {
                
                Text(habitName)
                    .font(.system(size: 16))
                
                Text(streakLabel)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.519))
                    .transition(.opacity)
                    .onReceive(timer, perform: { date in
                        timerLabel = "\(date)"
                        secondaryLabel = showTimer ? timerLabel : streakLabel
                    })
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
