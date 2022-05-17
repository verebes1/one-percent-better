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
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)
    ]) var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(habits, id: \.self.name) { habit in
                        HabitRow(habit: habit)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }
                .onAppear(perform: {
                    UITableView.appearance().contentInset.top = -25
                })
                
                Button("Add random habit") {
                    let habitNames = ["Ginny", "Harry", "Hermione", "Luna", "Ron", "Dumbledoor", "Voldemort"]
                    let name = habitNames.randomElement()!
                    let _ = try? Habit(context: moc, name: name)
                    CoreDataManager.shared.saveContext()
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Edit") {
//                        print("Edit tapped!")
//                    }
                    EditButton()
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [Habit] = habits.map{ $0 }

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the orderIndex attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
        }
        CoreDataManager.shared.saveContext()
    }
    
    private func delete(from source: IndexSet) {
        // Make an array of items from fetched results
        var revisedItems: [Habit] = habits.map{ $0 }
        
        // Remove the item to be deleted
        guard let index = source.first else { return }
        let habitToBeDeleted = revisedItems[index]
        revisedItems.remove(atOffsets: source)
        moc.delete(habitToBeDeleted)
        
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
            print("reverse Index: \(reverseIndex)")
        }
        CoreDataManager.shared.saveContext()
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
    
    @ObservedObject var habit: Habit
    
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
                
//                Text(habit.streakLabel)
                Text("\(habit.orderIndex)")
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
