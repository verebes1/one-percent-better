//
//  EditHabit.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/22/22.
//

import SwiftUI

class EditHabitViewModel: ObservableObject {
    
    @Published var trackerNavLinkActivate: [Tracker: Bool] = [:]
    
    init(habit: Habit) {
        habit.trackers.forEach { trackerAny in
            if let tracker = trackerAny as? Tracker {
                trackerNavLinkActivate[tracker] = false
            }
        }
    }
    
    func getTrackerNavLinkBinding(for tracker: Tracker) -> Binding<Bool> {
        return Binding {
            return self.trackerNavLinkActivate[tracker] ?? false
        } set: {
            self.trackerNavLinkActivate[tracker] = $0
        }

    }
}

struct EditHabit: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    var habit: Habit
    
    @Binding var show: Bool
    @State private var newHabitName: String
    
    /// Show empty habit name error if trying to save with empty habit name
    @State private var emptyHabitNameError = false
    
    @State private var newTimesPerDay: Int
    @State private var editFrequencyPresenting = false
    
    @ObservedObject var vm: EditHabitViewModel
    
    enum EditHabitError: Error {
        case emptyHabitName
    }
    
    init(habit: Habit, show: Binding<Bool>) {
        self.habit = habit
        self._show = show
        self._newHabitName = State(initialValue: habit.name)
        self.vm = EditHabitViewModel(habit: habit)
        self._newTimesPerDay = State(initialValue: habit.timesPerDay)
    }
    
    func delete() {
        
        // Remove the item to be deleted
        moc.delete(habit)
        
        // Get habits
        let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
        let habitController = Habit.resultsController(context: moc, sortDescriptors: sortDescriptors)
        let habits = habitController.fetchedObjects ?? []

        for reverseIndex in stride(from: habits.count - 1,
                                   through: 0,
                                   by: -1) {
            habits[reverseIndex].orderIndex = Int(reverseIndex)
        }
        moc.fatalSave()
    }
    
    /// Check if the user can save or needs to make changes
    /// - Returns: True if can save, false if changes needed
    func canSave() throws -> Bool {
        
        if newHabitName.isEmpty || newHabitName == "" {
            throw EditHabitError.emptyHabitName
        }
        
        return true
    }
    
    func saveProperties() {
        habit.name = newHabitName
        moc.fatalSave()
    }
    
    var body: some View {
        Background {
            VStack {
                List {
                    Section(header: Text("Habit")) {
                        EditHabitName(newHabitName: $newHabitName,
                                      emptyNameError: $emptyHabitNameError)
                        
                        NavigationLink(isActive: $editFrequencyPresenting) {
                            EditHabitFrequency(timesPerDay: habit.timesPerDay, show: $editFrequencyPresenting)
                                .environmentObject(habit)
                        } label: {
                            HStack {
                                Text("Frequency")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(habit.timesPerDay)x daily")
                            }
                        }
//                        .isDetailLink(false)

                        
                    }
                    
                    if habit.trackers.count > 0 {
                        Section(header: Text("Trackers")) {
                            ForEach(0 ..< habit.trackers.count, id: \.self) { i in
                                let tracker = habit.trackers[i] as! Tracker
                                let dest = EditTracker(habit: habit, tracker: tracker, show: vm.getTrackerNavLinkBinding(for: tracker))
                                NavigationLink(isActive: vm.getTrackerNavLinkBinding(for: tracker)) {
                                    dest
                                } label: {
                                    EditTrackerRowSimple(name: tracker.name)
                                }
                                .isDetailLink(false)
                            }
                        }
                    }
                    
                    Section {
                        Button {
                            delete()
                            show = false
                        } label: {
                            HStack {
                                Text("Delete Habit")
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
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            // Hide the system back button
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        do {
                            if try canSave() {
                                saveProperties()
                                show = false
                            }
                        } catch EditHabitError.emptyHabitName {
                            emptyHabitNameError = true
                        } catch {
                            fatalError("Unknown error in EditHabit")
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
}

struct EditHabit_Previews: PreviewProvider {
    
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
            EditHabit(habit: habit, show: .constant(true))
        }
    }
}

struct EditTrackerRowSimple: View {
    
    var name: String
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
        }
    }
}

struct EditHabitName: View {
    
    @Binding var newHabitName: String
    @Binding var emptyNameError: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Name")
                    .fontWeight(.medium)
                TextField("", text: $newHabitName)
                    .multilineTextAlignment(.trailing)
                    .frame(height: 30)
            }
            ErrorLabel(message: "Habit name can't be empty",
                       showError: $emptyNameError)
        }
    }
}
