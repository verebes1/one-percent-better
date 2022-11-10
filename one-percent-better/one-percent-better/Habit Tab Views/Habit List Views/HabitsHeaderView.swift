//
//  HabitsHeaderView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/3/22.
//

import SwiftUI
import CoreData
import Combine

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

class HeaderHabitsChanged: NSObject, NSFetchedResultsControllerDelegate, ObservableObject {
   let habitController: NSFetchedResultsController<Habit>
   let moc: NSManagedObjectContext
   
   init(moc: NSManagedObjectContext) {
      let sortDescriptors = [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true)]
      habitController = Habit.resultsController(context: moc,
                                                sortDescriptors: sortDescriptors)
      self.moc = moc
      super.init()
      habitController.delegate = self
      try? habitController.performFetch()
   }
   
   func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      print("Header habits changed")
      objectWillChange.send()
   }
}

class HeaderWeekViewModel: ObservableObject {
   
   var hlvm: HabitListViewModel
   
   /// The current selected day
   @Published var currentDay: Date = Date()
   
   /// The latest day that has been shown. This is updated when the
   /// app is opened or the view appears on a new day.
   @Published var latestDay: Date = Date()
   
   /// Which day is selected in the HabitHeaderView
   @Published var selectedWeekDay: Int = 0
   
   /// Which week is selected in the HabitHeaderView
   @Published var selectedWeek: Int = 0
   
   init(hlvm: HabitListViewModel) {
      self.hlvm = hlvm
      updateHeaderView()
   }
   
//   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//      if let fetchedHabit = firstResult,
//         habit != fetchedHabit {
//         print("New update for fetched habit \(fetchedHabit.name)")
//         self.habit = fetchedHabit
//
//      }
//      objectWillChange.send()
//   }
   
   /// Date formatter for the month year label at the top of the calendar
   var dateTitleFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.calendar = Calendar(identifier: .gregorian)
      dateFormatter.locale = Locale.autoupdatingCurrent
      dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
      return dateFormatter
   }()
   
   var navTitle: String {
      dateTitleFormatter.string(from: currentDay)
   }
   
   func updateHeaderView() {
      selectedWeekDay = thisWeekDayOffset(currentDay)
      selectedWeek = getSelectedWeek(for: currentDay)
   }
   
   func updateDayToToday() {
      if !Cal.isDate(latestDay, inSameDayAs: Date()) {
         latestDay = Date()
         currentDay = Date()
      }
      updateHeaderView()
   }
   
   /// Date of the earliest start date for all habits
   var earliestStartDate: Date {
      var earliest = Date()
      for habit in hlvm.habits {
         if habit.startDate < earliest {
            earliest = habit.startDate
         }
      }
      return earliest
   }
   
   /// Number of weeks (each row is a week) between today and the earliest completed habit
   var numWeeksSinceEarliest: Int {
      let numDays = Cal.dateComponents([.day], from: earliestStartDate, to: Date()).day!
      let diff = numDays - thisWeekDayOffset(Date()) + 6
      let weeks = diff / 7
      return weeks + 1
   }
   
   func getSelectedWeek(for day: Date) -> Int {
      let weekDayOffset = thisWeekDayOffset(day)
      let totalDayOffset = -(Cal.numberOfDaysBetween(day, and: Date()) - 1)
      let weekNum = (weekDayOffset - totalDayOffset - 1) / 7
      let result = numWeeksSinceEarliest - 1 - weekNum
      return result
   }
   
   func thisWeekDayOffset(_ date: Date) -> Int {
      return Cal.component(.weekday, from: date) - 1
   }
   
   /// The number of days to offset from today to get to the selected day
   /// - Parameters:
   ///   - week: Selected week, (numWeeksSinceEarliest - 1) == current week, 0 == earliest week
   ///   - day: Selected day,  [0,1,2,3,4,5,6]
   /// - Returns: Integer offset, yesterday is -1, today is 0, tomorrow is 1, etc.
   func dayOffset(week: Int, day: Int) -> Int {
      let numDaysBack = day - thisWeekDayOffset(Date())
      let numWeeksBack = week - (numWeeksSinceEarliest - 1)
      if numWeeksBack == 0 {
         return numDaysBack
      } else {
         return (numWeeksBack * 7) + numDaysBack
      }
   }
   
   func dayOffsetToToday(from date: Date) -> Int {
      let result = -(Cal.numberOfDaysBetween(date, and: Date()) - 1)
      return result
   }
   
   func dayOffsetFromEarliest(week: Int, day: Int) -> Int {
      let numDaysBack = day - thisWeekDayOffset(earliestStartDate)
      let numWeeksBack = week
      if numWeeksBack == 0 {
         return numDaysBack
      } else {
         return (numWeeksBack * 7) + numDaysBack
      }
   }
   
   func date(week: Int, day: Int) -> Date {
      return Cal.date(byAdding: .day, value: dayOffset(week: week, day: day), to: Date())!
   }
   
   func percent(week: Int, day: Int) -> Double {
      let day = date(week: week, day: day)
      var numCompleted: Double = 0
      var total: Double = 0
      for habit in hlvm.habits {
         if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
            habit.isDue(on: day) {
            total += 1
         }
      }
      guard total > 0 else { return 0 }
      
      for habit in hlvm.habits {
//         if habit.isDue(on: day) {
            numCompleted += habit.percentCompleted(on: day)
//         }
      }
      return numCompleted / total
   }
}

struct HabitsHeaderView: View {
   
   @Environment(\.managedObjectContext) var moc
   @EnvironmentObject var vm: HeaderWeekViewModel
   
   @ObservedObject var hc: HeaderHabitsChanged
   
   var color: Color = .systemTeal
   
   var body: some View {
      print(" - HabitsHeaderView body")
      let _ = Self._printChanges()
      return (
         VStack(spacing: 0) {
         HStack {
            ForEach(0 ..< 7) { i in
               SelectedDayView(index: i,
                               color: color)
               .environmentObject(vm)
            }
         }
         .padding(.horizontal, 20)
         
         let ringSize: CGFloat = 27
         TabView(selection: $vm.selectedWeek) {
            ForEach(0 ..< vm.numWeeksSinceEarliest, id: \.self) { i in
               HStack {
                  ForEach(0 ..< 7) { j in
                     let dayOffset = vm.dayOffset(week: i, day: j)
                     let dayOffsetFromEarliest = vm.dayOffsetFromEarliest(week: i, day: j)
                     let percent = vm.percent(week: i, day: j)
                     RingView(percent: percent,
                              color: color,
                              size: ringSize,
                              withText: true)
                     .font(.system(size: 14))
                     .frame(maxWidth: .infinity)
                     .onTapGesture {
                        if dayOffset <= 0 && dayOffsetFromEarliest >= 0 {
                           vm.selectedWeekDay = j
                           let newDay = Cal.date(byAdding: .day, value: dayOffset, to: Date())!
                           vm.currentDay = newDay
                        }
                     }
                     .contentShape(Rectangle())
                     .opacity((dayOffset > 0 || dayOffsetFromEarliest < 0) ? 0.4 : 1)
                  }
               }
               .padding(.horizontal, 20)
            }
         }
         .coordinateSpace(name: "scroll")
         .frame(height: ringSize + 22)
         .tabViewStyle(.page(indexDisplayMode: .never))
         .onChange(of: vm.selectedWeek) { newWeek in
            print("new selected week!")
            // If scrolling to week which has dates ahead of today
            let today = Date()
            let currentOffset = vm.thisWeekDayOffset(today)
            if newWeek == (vm.numWeeksSinceEarliest - 1),
               vm.selectedWeekDay > currentOffset {
               vm.selectedWeekDay = currentOffset
            }
            
            // If scrolls to week which has days before the earliest start date
            if vm.date(week: newWeek, day: vm.selectedWeekDay) < vm.earliestStartDate {
               vm.selectedWeekDay = vm.thisWeekDayOffset(vm.earliestStartDate)
            }
            
            let dayOffset = vm.dayOffset(week: newWeek, day: vm.selectedWeekDay)
            let newDay = Cal.date(byAdding: .day, value: dayOffset, to: today)!
            vm.currentDay = newDay
         }
      }
      )
   }
   
}

struct HabitsListHeaderView_Previews: PreviewProvider {
   
   @State static var currentDay = Date()
   
   static func habitsListHeaderData() -> [Habit] {
      let context = CoreDataManager.previews.mainContext
      
      let day0 = Date()
      let day1 = Cal.date(byAdding: .day, value: -1, to: day0)!
      let day2 = Cal.date(byAdding: .day, value: -9, to: day0)!
      
      let h1 = try? Habit(context: context, name: "Cook")
      h1?.markCompleted(on: day0)
      h1?.markCompleted(on: day1)
      h1?.markCompleted(on: day2)
      
      let h2 = try? Habit(context: context, name: "Clean")
      h2?.markCompleted(on: day1)
      h2?.markCompleted(on: day2)
      
      let h3 = try? Habit(context: context, name: "Laundry")
      h3?.markCompleted(on: day2)
      
      let habits = Habit.habits(from: context)
      return habits
   }
   
   static var previews: some View {
      //        let habits = habitsListHeaderData()
      
      let moc = CoreDataManager.previews.mainContext
      let vm = HabitListViewModel(moc)
      let hwvm = HeaderWeekViewModel(hlvm: vm)
      HabitsHeaderView(hc: HeaderHabitsChanged(moc: moc))
         .environment(\.managedObjectContext, moc)
         .environmentObject(hwvm)
   }
}

struct SelectedDayView: View {
   
   @EnvironmentObject var vm: HeaderWeekViewModel
   var index: Int
   var color: Color = .systemTeal
   
   func isIndexSameAsToday(_ index: Int) -> Bool {
      let dayIsSelectedWeekday = vm.thisWeekDayOffset(Date()) == index
      let weekIsSelectedWeek = vm.selectedWeek == (vm.numWeeksSinceEarliest - 1)
      return dayIsSelectedWeekday && weekIsSelectedWeek
   }
   
   let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
   
   var body: some View {
      ZStack {
         let circleSize: CGFloat = 19
         let isSelected = index == vm.thisWeekDayOffset(vm.currentDay)
         if isSelected {
            Circle()
               .foregroundColor(isIndexSameAsToday(index) ? color : .systemGray2)
               .frame(width: circleSize, height: circleSize)
         }
         Text(smwttfs[index])
            .font(.system(size: 12))
            .fontWeight(isIndexSameAsToday(index) && !isSelected ? .medium : .regular)
            .foregroundColor(isSelected ? .white : (isIndexSameAsToday(index) ? color : .secondary))
            .frame(maxWidth: .infinity)
      }
      .padding(.bottom, 3)
      .contentShape(Rectangle())
      .onTapGesture {
         let dayOffset = vm.dayOffset(week: vm.selectedWeek, day: index)
         if dayOffset <= 0 {
            vm.selectedWeekDay = index
            vm.currentDay = Cal.date(byAdding: .day, value: dayOffset, to: Date())!
         }
      }
   }
}
