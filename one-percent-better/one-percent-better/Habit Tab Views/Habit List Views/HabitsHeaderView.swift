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

class HeaderSelectionViewModel: ObservableObject {
   
   /// Which day is selected in the HabitHeaderView
   @Published var selectedWeekDay = 0
   
   /// Which week is selected in the HabitHeaderView
   @Published var selectedWeek = 0
   
   @Published var selectedDay = Date()
   
   /// The latest day that has been shown. This is updated when the
   /// app is opened or the view appears on a new day.
   @Published var latestDay = Date()
   
   /// Date formatter for the month year label at the top of the calendar
   var dateTitleFormatter: DateFormatter = {
      let dateFormatter = DateFormatter()
      dateFormatter.calendar = Calendar(identifier: .gregorian)
      dateFormatter.locale = Locale.autoupdatingCurrent
      dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, YYYY")
      return dateFormatter
   }()
   
   var navTitle: String {
      dateTitleFormatter.string(from: selectedDay)
   }
   
   let hwvm: HeaderWeekViewModel
   
   init(hwvm: HeaderWeekViewModel) {
      self.hwvm = hwvm
      updateHeaderView()
      hwvm.updateImprovementScores(on: selectedDay)
   }
   
   func updateHeaderView() {
      selectedWeekDay = hwvm.thisWeekDayOffset(selectedDay)
      selectedWeek = hwvm.getSelectedWeek(for: selectedDay)
   }
   
   func updateDayToToday() {
      if !Cal.isDate(latestDay, inSameDayAs: Date()) {
         latestDay = Date()
         selectedDay = Date()
         updateHeaderView()
         hwvm.updateImprovementScores(on: selectedDay)
      }
   }
   
   func updateWeek(to newWeek: Int) {
      // If scrolling to week which has dates ahead of today
      let today = Date()
      let currentOffset = hwvm.thisWeekDayOffset(today)
      if newWeek == (hwvm.numWeeksSinceEarliest - 1),
         selectedWeekDay > currentOffset {
         selectedWeekDay = currentOffset
      }

      // If scrolls to week which has days before the earliest start date
      if hwvm.date(week: newWeek, day: selectedWeekDay) < hwvm.earliestStartDate {
         selectedWeekDay = hwvm.thisWeekDayOffset(hwvm.earliestStartDate)
      }

      let dayOffset = hwvm.dayOffset(week: newWeek, day: selectedWeekDay)
      let newDay = Cal.date(byAdding: .day, value: dayOffset, to: today)!
      selectedDay = newDay
   }
}

class HeaderWeekViewModel: ConditionalNSManagedObjectFetcher<Habit> {
   
   @Published var habits: [Habit] = []
   
   init(_ context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
      super.init(context)
      habits = fetchedObjects
   }
   
   override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      habits = controller.fetchedObjects as? [Habit] ?? []
   }
   
   func updateImprovementScores(on date: Date) {
      for habit in habits {
         habit.improvementTracker?.update(on: date)
      }
   }
   
   /// Date of the earliest start date for all habits
   var earliestStartDate: Date {
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
      let numDays = Cal.dateComponents([.day], from: earliestStartDate, to: Date()).day!
      let diff = numDays - thisWeekDayOffset(Date()) + 6
      let weeks = diff / 7
      return weeks + 1
   }
   
   func getSelectedWeek(for day: Date) -> Int {
      let weekDayOffset = thisWeekDayOffset(day)
      let totalDayOffset = -(Cal.numberOfDaysBetween(day, and: Date()))
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
      let result = -(Cal.numberOfDaysBetween(date, and: Date()))
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
      return percent(on: day)
   }
   
   func percent(on day: Date) -> Double {
      var numCompleted: Double = 0
      var total: Double = 0
      for habit in habits {
         if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
            habit.isDue(on: day) {
            total += 1
         }
      }
      guard total > 0 else { return 0 }
      
      for habit in habits {
         if Cal.startOfDay(for: habit.startDate) <= Cal.startOfDay(for: day),
            habit.isDue(on: day) {
            numCompleted += habit.percentCompleted(on: day)
         }
      }
      return numCompleted / total
   }
}

struct HabitsHeaderView: View {
   
   @Environment(\.managedObjectContext) var moc
   @ObservedObject var vm = HeaderWeekViewModel()
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   var color: Color = .systemTeal
   
   init(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
      print("Habit header view init")
   }
   
   var body: some View {
      let _ = Self._printChanges()
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
         TabView(selection: $hsvm.selectedWeek) {
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
                           hsvm.selectedWeekDay = j
                           let newDay = Cal.date(byAdding: .day, value: dayOffset, to: Date())!
                           hsvm.selectedDay = newDay
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
         .onChange(of: hsvm.selectedWeek) { newWeek in
            hsvm.updateWeek(to: newWeek)
         }
      }
      
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
      let moc = CoreDataManager.previews.mainContext
      let hwvm = HeaderWeekViewModel(moc)
      HabitsHeaderView(context: moc)
         .environment(\.managedObjectContext, moc)
         .environmentObject(hwvm)
   }
}

struct SelectedDayView: View {
   
   @EnvironmentObject var vm: HeaderWeekViewModel
   @EnvironmentObject var hsvm: HeaderSelectionViewModel
   
   var index: Int
   var color: Color = .systemTeal
   
   func isIndexSameAsToday(_ index: Int) -> Bool {
      let dayIsSelectedWeekday = vm.thisWeekDayOffset(Date()) == index
      let weekIsSelectedWeek = hsvm.selectedWeek == (vm.numWeeksSinceEarliest - 1)
      return dayIsSelectedWeekday && weekIsSelectedWeek
   }
   
   let smwttfs = ["S", "M", "T", "W", "T", "F", "S"]
   
   var body: some View {
      ZStack {
         let circleSize: CGFloat = 19
         let isSelected = index == vm.thisWeekDayOffset(hsvm.selectedDay)
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
         let dayOffset = vm.dayOffset(week: hsvm.selectedWeek, day: index)
         if dayOffset <= 0 {
            hsvm.selectedWeekDay = index
            hsvm.selectedDay = Cal.date(byAdding: .day, value: dayOffset, to: Date())!
         }
      }
   }
}
