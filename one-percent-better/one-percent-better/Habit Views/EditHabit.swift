//
//  EditHabit.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/22/22.
//

import SwiftUI

struct EditHabit: View {
    
    @Environment(\.managedObjectContext) var moc
    
    var habit: Habit
    @Binding var rootPresenting: Bool
    
    @State var habitName: String
    
    init(habit: Habit, rootPresenting: Binding<Bool>) {
        self.habit = habit
        self._rootPresenting = rootPresenting
        habitName = habit.name
    }
    
    func delete(from source: IndexSet) {
        // Make an array from fetched results
        var revisedItems: [Tracker] = habit.trackers.map { $0 as! Tracker }
        
        // Remove the item to be deleted
        guard let index = source.first else { return }
        let trackerToBeDeleted = revisedItems[index]
        revisedItems.remove(atOffsets: source)
        moc.delete(trackerToBeDeleted)
        
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].index = Int(reverseIndex)
        }
        moc.fatalSave()
    }
    
    var body: some View {
        Background {
            /*ScrollView*/VStack {
                VStack(alignment: .leading, spacing: 10) {
        
                    Spacer().frame(height: 10)
                    
                    CardView(shadow: false, padding: false) {
                        VStack {
                            
                            // Habit name
                            HStack {
                                Text("Name")
                                    .fontWeight(.medium)
                                
                                TextField("", text: $habitName)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                    .frame(height: 45)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer().frame(height: 10)
                    
                    HStack {
                        Text("Trackers")
                            .font(.title)
                        .fontWeight(.medium)
                        
                        Spacer()
                        
                        EditButton()
                    }
                    
                    
                    List {
                        ForEach(0 ..< habit.trackers.count, id: \.self) { i in
                            if let t = habit.trackers[i] as? Tracker {
                                Text(t.name)
                            }
                        }
                        .onDelete(perform: delete(from:))
                    }
                    
                    
//                    CardView {
//                        // Tracker list
//                        VStack(alignment: .leading) {
//                            ForEach(0 ..< habit.trackers.count, id: \.self) { i in
//                                if let t = habit.trackers[i] as? Tracker {
//                                    Text(t.name)
//                                }
//                            }
//                        }
//                    }
                }
                .padding(.horizontal, 20)
                
            }
//            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: EmptyView()) {
                            Text("Save")
                        }
                }
            }
        }
    }
}

struct EditHabit_Previews: PreviewProvider {
    
    @State static var isPresenting: Bool = false
    
    static func data() -> Habit {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
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
        
        let habits = Habit.habitList(from: context)
        return habits.first!
    }
    
    static var previews: some View {
        let habit = data()
        NavigationView {
            EditHabit(habit: habit, rootPresenting: $isPresenting)
        }
    }
}
