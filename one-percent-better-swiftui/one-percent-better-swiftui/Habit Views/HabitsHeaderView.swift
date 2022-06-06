//
//  HabitsHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI
import CoreData

class HabitsHeaderViewModel: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
    private let habitController: NSFetchedResultsController<Habit>
    
    init(_ context: NSManagedObjectContext) {
        let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
        habitController = Habit.resultsController(context: context, sortDescriptors: sortDescriptors)
        super.init()
        habitController.delegate = self
        try? habitController.performFetch()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
    
    var habits: [Habit] {
        return habitController.fetchedObjects ?? []
    }
    
    /// Date of the earliest completed habit in the habit list
    var earliestCompleted: Date {
        var earliest = Date()
        for habit in habits {
            if habit.startDate < earliest {
                earliest = habit.startDate
            }
        }
        return earliest
    }
    
    /// Number of weeks (each row is a week) between today and the earliest completed habit
    var numWeeksSinceEarliest: Int {
        let thisWeekOffset = Calendar.current.component(.weekday, from: Date()) - 1
        let numDays = Calendar.current.dateComponents([.day], from: earliestCompleted, to: Date()).day!
        let diff = numDays - thisWeekOffset
        if diff < 0 { return 1 }
        let weeks = diff / 7
        return weeks + 2
    }
    
    /// The number of days to offset from today to get to the selected day
    /// - Parameters:
    ///   - week: Selected week, (numWeeksSinceEarliest - 1) == current week
    ///   - day: Selected day,  [0,1,2,3,4,5,6]
    /// - Returns: Integer offset, yesterday is -1, today is 0, tomorrow is 1, etc.
    func dayOffset(week: Int, day: Int) -> Int {
        let numDaysBack = day - thisWeekOffset(Date())
        let numWeeksBack = week - (numWeeksSinceEarliest - 1)
        if numWeeksBack == 0 {
            return numDaysBack
        } else {
            return (numWeeksBack * 7) + numDaysBack
        }
    }
    
    func date(week: Int, day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: dayOffset(week: week, day: day), to: Date())!
    }
    
    func percent(week: Int, day: Int) -> Double {
        let day = date(week: week, day: day)
        var numCompleted: Double = 0
        let total: Double = Double(habits.count)
        guard total > 0 else { return 0 }
        for habit in habits {
            if habit.wasCompleted(on: day) {
                numCompleted += 1
            }
        }
        return numCompleted / total
    }
}

fileprivate func thisWeekOffset(_ date: Date) -> Int {
    return Calendar.current.component(.weekday, from: date) - 1
}

struct HabitsHeaderView: View {
    
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: HabitsHeaderViewModel
    @Binding var currentDay: Date
    @State var selectedWeekDay = 0
    @State var selectedWeek = 0
    var color: Color = .systemTeal
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0 ..< 7) { i in
                    SelectedDayView(index: i,
                                    selectedWeekDay: $selectedWeekDay,
                                    selectedWeek: $selectedWeek,
                                    currentDay: $currentDay,
                                    color: color)
                    .environmentObject(viewModel)
                }
            }
            .padding(.horizontal, 20)
            
            let ringSize: CGFloat = 27
            TabView(selection: $selectedWeek) {
                ForEach(0 ..< viewModel.numWeeksSinceEarliest, id: \.self) { i in
                    HStack {
                        ForEach(0 ..< 7) { j in
                            let dayOffset = viewModel.dayOffset(week: i, day: j)
                            let percent = viewModel.percent(week: i, day: j)
                            RingView(percent: percent,
                                     color: color,
                                     size: ringSize,
                                     withText: true)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                let dayOffset = viewModel.dayOffset(week: i, day: j)
                                if dayOffset <= 0 {
                                    selectedWeekDay = j
                                    let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
                                    currentDay = newDay
                                }
                            }
                            .contentShape(Rectangle())
                            .opacity(dayOffset > 0 ? 0.4 : 1)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(height: ringSize + 22)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: selectedWeek, perform: { _ in
                let thisWeekOffset = thisWeekOffset(Date())
                if selectedWeek == (viewModel.numWeeksSinceEarliest - 1),
                   selectedWeekDay > thisWeekOffset {
                    selectedWeekDay = thisWeekOffset
                }
                
                let dayOffset = viewModel.dayOffset(week: selectedWeek, day: selectedWeekDay)
                let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
                currentDay = newDay
            })
        }
        .onAppear {
            selectedWeekDay = thisWeekOffset(currentDay)
            selectedWeek = viewModel.numWeeksSinceEarliest - 1
        }
    }
    
}

struct HabitsListHeaderView_Previews: PreviewProvider {
    
    @State static var currentDay = Date()
    
    static func habitsListHeaderData() {
        let context = CoreDataManager.previews.persistentContainer.viewContext
        
        let day0 = Date()
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day0)!
        let day2 = Calendar.current.date(byAdding: .day, value: -2, to: day0)!
        
        let h1 = try? Habit(context: context, name: "Cook")
        h1?.markCompleted(on: day0)
        h1?.markCompleted(on: day1)
        h1?.markCompleted(on: day2)
        
        let h2 = try? Habit(context: context, name: "Clean")
        h2?.markCompleted(on: day1)
        h2?.markCompleted(on: day2)
        
        let h3 = try? Habit(context: context, name: "Laundry")
        h3?.markCompleted(on: day2)
    }
    
    static var previews: some View {
        let _ = habitsListHeaderData()
        let context = CoreDataManager.previews.persistentContainer.viewContext
        HabitsHeaderView(viewModel: HabitsHeaderViewModel(context),
                             currentDay: $currentDay)
        .environment(\.managedObjectContext, CoreDataManager.previews.persistentContainer.viewContext)
    }
}

struct SelectedDayView: View {
    
    @EnvironmentObject var viewModel: HabitsHeaderViewModel
    var index: Int
    @Binding var selectedWeekDay: Int
    @Binding var selectedWeek: Int
    @Binding var currentDay: Date
    var color: Color = .systemTeal
    
    func selectedIsToday(_ index: Int) -> Bool {
        let currentDayIsToday = Calendar.current.isDateInToday(currentDay)
        let selectedDayIsToday = thisWeekOffset(currentDay) == index
        let weekIsToday = selectedWeek == (viewModel.numWeeksSinceEarliest - 1)
        return currentDayIsToday && selectedDayIsToday && weekIsToday
    }
    
    let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        ZStack {
            let circleSize: CGFloat = 19
            let isSelected = index == selectedWeekDay
            if isSelected {
                Circle()
                    .foregroundColor(selectedIsToday(index) ? color : .systemGray2)
                    .frame(width: circleSize, height: circleSize)
            }
            Text(smwttfs[index])
                .font(.system(size: 12))
                .fontWeight(.regular)
                .foregroundColor(isSelected ? .white : (selectedIsToday(index) ? color : .secondary))
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            let dayOffset = viewModel.dayOffset(week: selectedWeek, day: index)
            if dayOffset <= 0 {
                selectedWeekDay = index
                currentDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            }
        }
    }
}
