//
//  EditTracker.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 8/8/22.
//

import SwiftUI

struct EditTracker: View {
    
    @Environment(\.managedObjectContext) var moc
    
    var habit: Habit
    var tracker: Tracker
    
    @State private var trackerName: String
    @Binding var show: Bool
    
    init(habit: Habit, tracker: Tracker, show: Binding<Bool>) {
        self.habit = habit
        self.tracker = tracker
        self._trackerName = State(initialValue: tracker.name)
        self._show = show
    }
    
    func delete() {
        // Make an array from fetched results
        var revisedItems: [Tracker] = habit.trackers.map { $0 as! Tracker }

        for (i, t) in revisedItems.enumerated() {
            if tracker == t {
                revisedItems.remove(at: i)
            }
        }
        
        // Remove the item to be deleted
        moc.delete(tracker)

        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1) {
            revisedItems[reverseIndex].index = Int(reverseIndex)
        }
        moc.fatalSave()
    }
    
    var body: some View {
        Background {
            VStack {
                List {
                    Section {
                        HStack {
                            Text("Name")
                                .fontWeight(.medium)
                            TextField("", text: $trackerName)
                                .multilineTextAlignment(.trailing)
                                .frame(height: 30)
                        }
                    }
                    
                    Section {
                        Button {
                            delete()
                            show = false
                        } label: {
                            HStack {
                                Text("Delete Tracker")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
//        .overlay(
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .foregroundColor(.cardColor)
//                    .padding(.horizontal, 15)
//
//                Text("Are you sure you want to delete \(tracker.name)?")
//
//                HStack {
//
//                }
//            }
//            .frame(height: 100)
//        )
    }
}

struct EditTracker_Previews: PreviewProvider {
    
    static func data() -> (Habit, NumberTracker) {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Swimming")
        h1?.markCompleted(on: day2)
        
        if let h1 = h1 {
            let t1 = NumberTracker(context: context, habit: h1, name: "Laps")
            t1.add(date: day0, value: "3")
            t1.add(date: day1, value: "2")
            t1.add(date: day2, value: "1")
        }
        
        let habits = Habit.habitList(from: context)
        return (habits.first!, habits.first!.trackers.firstObject as! NumberTracker)
    }
    
    static var previews: some View {
        let t = data()
        NavigationView {
            EditTracker(habit: t.0, tracker: t.1, show: .constant(true))
        }
    }
}
