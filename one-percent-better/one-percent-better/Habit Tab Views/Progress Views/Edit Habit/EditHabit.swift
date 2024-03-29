//
//  EditHabit.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/22/22.
//

import SwiftUI
import CoreData
import Combine

enum EditHabitNavRoute: Hashable {
    case editFrequency
    case editNotification
    case editTracker(Tracker)
}

struct EditHabit: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var nav: HabitTabNavPath
    @EnvironmentObject var vm: ProgressViewModel
    @EnvironmentObject var tm: TrackersViewModel
    
    @ObservedObject private var sowm = StartOfWeekModel.shared
    
    @State private var newHabitName: String
    
    /// Show empty habit name error if trying to save with empty habit name
    @State private var emptyHabitNameError = false
    @State private var startDate: Date
    @State private var confirmDeleteHabit: Bool = false
    @State private var isGoingToDelete = false
    
    enum EditHabitError: Error {
        case emptyHabitName
    }
    
    init(habit: Habit) {
        self._newHabitName = State(initialValue: habit.name)
        self._startDate = State(initialValue: habit.startDate)
    }
    
    /// Check if the user can save or needs to make changes
    /// - Returns: True if can save, false if changes needed
    func canSave() throws -> Bool {
        if newHabitName.isEmpty || newHabitName == "" || newHabitName.trimmingCharacters(in: .whitespaces).isEmpty {
            throw EditHabitError.emptyHabitName
        }
        return true
    }
    
    var freqTextView: some View {
        switch vm.habit.frequency(on: Date()) {
        case .timesPerDay(let n):
            let timesString = n == 1 ? "time" : "times"
            return Text("\(n) \(timesString) per day")
        case .specificWeekdays(let days):
            var finalString = ""
            for weekday in Weekday.orderedCases {
                if days.contains(weekday) {
                    finalString += weekday.threeLetter
                    finalString += ", "
                }
            }
            if finalString.count >= 2 {
                finalString = String(finalString.dropLast(2))
            }
            return Text(finalString)
        case .timesPerWeek(times: let n, resetDay: let resetDay):
            let timesString = n == 1 ? "time" : "times"
            let finalString = "\(n) \(timesString) per week, every \(resetDay)"
            return Text(finalString)
        case .none:
            return Text("Unknown frequency")
        }
    }
    
    var body: some View {
        let _ = Self._printChanges()
        Background {
            VStack {
                List {
                    Section(header: Text("Habit")) {
                        EditHabitName(newHabitName: $newHabitName,
                                      emptyNameError: $emptyHabitNameError)
                        
                        // MARK: - Edit Frequency
                        
                        NavigationLink(value: EditHabitNavRoute.editFrequency) {
                            HStack {
                                IconTextRow(title: "Frequency", icon: "clock.arrow.2.circlepath", color: .indigo)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                freqTextView
                            }
                        }
                        
                        // MARK: - Edit Notifications
                        
                        NavigationLink(value: EditHabitNavRoute.editNotification) {
                            HStack {
                                IconTextRow(title: "Notifications", icon: "bell.fill", color: .pink)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                EditHabitNotificationRow(count: vm.habit.notificationsArray.count)
                            }
                        }
                        
                        // MARK: - Edit Start Date
                        
                        HStack {
                            IconTextRow(title: "Start date", icon: "calendar", color: .orange)
                                .fontWeight(.medium)
                            Spacer()
                            
                            let range = Cal.add(days: -10000) ... (vm.habit.firstCompleted ?? Date())
                            DatePicker("", selection: $startDate, in: range, displayedComponents: [.date])
                                .frame(height: 50)
                        }
                        .onChange(of: startDate) { newValue in
                            vm.habit.updateStartDate(to: newValue)
                        }
                        
                    }
                    .listRowBackground(Color.cardColor)
                    
                    if tm.trackers.count > 0 {
                        Section(header: Text("Trackers")) {
                            ForEach(tm.trackers) { tracker in
                                NavigationLink(value: EditHabitNavRoute.editTracker(tracker)) {
                                    EditTrackerRow(tracker: tracker, name: tracker.name)
                                }
                            }
                        }
                        .listRowBackground(Color.cardColor)
                    }
                    
                    Section {
                        Button {
                            confirmDeleteHabit = true
                        } label: {
                            HStack {
                                Text("Delete Habit")
                                    .foregroundColor(.red)
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .alert(
                            "Are you sure you want to delete your habit \"\(vm.habit.name)\"?",
                            isPresented: $confirmDeleteHabit
                        ) {
                            Button("Delete", role: .destructive) {
                                nav.path.removeLast(2)
                                isGoingToDelete = true
                            }
                        }
                    }
                    .listRowBackground(Color.cardColor)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: EditHabitNavRoute.self) { route in
                if case .editFrequency = route {
                    EditHabitFrequency(habit: vm.habit)
                        .environmentObject(vm)
                }
                
                if case let .editTracker(tracker) = route {
                    EditTracker(tracker: tracker)
                        .environmentObject(vm)
                }
                
                if case .editNotification = route {
                    EditHabitNotifications()
                        .environmentObject(vm)
                }
            }
            .onDisappear {
                if !isGoingToDelete {
                    do {
                        if try canSave() && newHabitName != vm.habit.name {
                            vm.habit.updateName(to: newHabitName)
                            moc.assertSave()
                        }
                    } catch {
                        // do nothing
                    }
                } else {
                    vm.deleteHabit()
                }
            }
            .onAppear {
                print("Edit habit appearing!")
            }
        }
    }
}

struct EditHabitPreviewer: View {
    let habit: Habit
    @StateObject private var nv = HabitTabNavPath()
    
    var body: some View {
        NavigationStack(path: $nv.path) {
            EditHabit(habit: habit)
                .environmentObject(nv)
                .environmentObject(ProgressViewModel(habit: habit))
                .environmentObject(TrackersViewModel(habit: habit))
        }
    }
}

struct EditHabit_Previews: PreviewProvider {
    
    static func data() -> Habit {
        let context = CoreDataManager.previews.mainContext
        
        let day0 = Date()
        let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Cal.date(byAdding: .day, value: -2, to: day0)!
        
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
            
            let _ = ExerciseTracker(context: context, habit: h1, name: "Bench Press")
        }
        
        let habits = Habit.habits(from: context)
        return habits.first!
    }
    
    static var previews: some View {
        let habit = data()
        NavigationView {
            EditHabitPreviewer(habit: habit)
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

struct EditTrackerRow: View {
    
    var tracker: Tracker
    var name: String
    
    //   init(tracker: Tracker) {
    //      self.tracker = tracker
    //      print("Edit Tracker row init! for tracker: \(tracker.name)")
    //   }
    
    var body: some View {
        let _ = Self._printChanges()
        HStack {
            if tracker is GraphTracker {
                IconTextRow(title: name, icon: "chart.xyaxis.line", color: .blue)
            } else if tracker is ImageTracker {
                IconTextRow(title: name, icon: "photo", color: .mint)
            } else if tracker is ExerciseTracker {
                IconTextRow(title: name, icon: "figure.walk", color: .red)
            } else {
                Text(name)
                //            IconTextRow(title: tracker.name, icon: "chart.xyaxis.line", color: .blue)
            }
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
                IconTextRow(title: "Name", icon: "square.and.pencil", color: .systemYellow)
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

struct EditHabitNotificationRow: View {
    
    var count: Int
    
    var label: String {
        count == 0 ? "None" : "\(count)"
    }
    
    var body: some View {
        Text(label)
            .foregroundColor(count == 0 ? .secondaryLabel : .primary)
    }
}
