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
    
    var newHabit: String? = nil
    
    @State var isHabitsViewPresenting: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(habits, id: \.self.name) { habit in
                        NavigationLink(
                            destination: ProgressView().environmentObject(habit)) {
                            HabitRow()
                                .environmentObject(habit)
                        }
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }
                .onAppear(perform: {
                    UITableView.appearance().contentInset.top = -25
                })
                
//                Button("Add random habit") {
//                    let habitNames = ["Ginny", "Harry", "Hermione", "Luna", "Ron", "Dumbledoor", "Voldemort"]
//                    let name = habitNames.randomElement()!
//                    let _ = try? Habit(context: moc, name: name)
//                    try? moc.save()
//                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: CreateNewHabit(rootPresenting: $isHabitsViewPresenting),
                        isActive: $isHabitsViewPresenting) {
                            Image(systemName: "square.and.pencil")
                        }
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if let newHabit = newHabit {
                let _ = try? Habit(context: moc, name: newHabit)
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        // Make an array from fetched results
        var revisedItems: [Habit] = habits.map{ $0 }
        
        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        // Update the orderIndex indices
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].orderIndex = Int(reverseIndex)
        }
        try? moc.save()
    }
    
    private func delete(from source: IndexSet) {
        // Make an array from fetched results
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
        }
        try? moc.save()
    }
}

struct HabitsView_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewData.habitViewData()

        return HabitsView()
            .environment(\.managedObjectContext, CoreDataManager.previews.persistentContainer.viewContext)
    }
}

struct HabitRow: View {
    
    @EnvironmentObject var habit: Habit
    
    var body: some View {
        HStack {
            VStack {
                HabitCompletionCircle(completed: habit.wasCompleted(on: Date()),
                                      size: 28)
            }
            VStack(alignment: .leading) {
                
                Text(habit.name)
                    .font(.system(size: 16))
                
                Text(habit.streakLabel)
                    .font(.system(size: 11))
                    .foregroundColor(habit.streakLabelColor)
            }
            Spacer()
        }
    }
}
