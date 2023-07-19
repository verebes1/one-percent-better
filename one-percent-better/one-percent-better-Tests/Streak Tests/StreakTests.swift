//
//  StreakTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 5/15/23.
//

import XCTest
import CoreData
@testable import One_Percent_Better

final class StreakTests: XCTestCase {

   let context = CoreDataManager.previews.mainContext
   
   var habit: Habit!
   
   var df: DateFormatter {
      let df = DateFormatter()
      df.dateFormat = "MM-dd-yyyy"
      return df
   }
   
   override func setUpWithError() throws {
      habit = try! Habit(context: context, name: "Cook")
   }
   
   override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      let habits = Habit.habits(from: context)
      for habit in habits {
         context.delete(habit)
      }
      try context.save()
   }
   
   // MARK: Specific Weekday Tests
   
   func testSpecifificWeekdayStreak() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .specificWeekdays([.wednesday, .thursday]), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 1)
      let thursday = Cal.add(days: 1, to: startWednesday)
      XCTAssertEqual(habit.streak(on: thursday), 1)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: thursday)), 0)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: thursday)), 0)
      
      habit.markCompleted(on: thursday)
      XCTAssertEqual(habit.streak(on: thursday), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startWednesday)), 2) // friday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startWednesday)), 2) // saturday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startWednesday)), 2) // sunday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 5, to: startWednesday)), 2) // monday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 6, to: startWednesday)), 2) // tuesday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startWednesday)), 2) // wednesday (DUE)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 8, to: startWednesday)), 0) // thursday (DUE)
      
      habit.markCompleted(on: Cal.add(days: 1, to: thursday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 2) // thursday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startWednesday)), 3) // friday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startWednesday)), 3) // saturday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startWednesday)), 3) // sunday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 5, to: startWednesday)), 3) // monday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 6, to: startWednesday)), 3) // tuesday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startWednesday)), 3) // wednesday (DUE)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 8, to: startWednesday)), 0) // thursday (DUE)
   }
   
   
   func testSpecifificWeekdayStreak2() {
      let startMonday = df.date(from: "12-5-2022")!
      habit.updateStartDate(to: startMonday)
      habit.changeFrequency(to: .specificWeekdays([.sunday]), on: startMonday)
      
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startMonday)), 0)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startMonday)), 0)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startMonday)), 0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startMonday))
      XCTAssertEqual(habit.streak(on: startMonday), 0)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startMonday)), 1) // tuesday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 2, to: startMonday)), 1) // wednesday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 3, to: startMonday)), 1) // thursday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 4, to: startMonday)), 1) // friday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 5, to: startMonday)), 1) // saturday
      XCTAssertEqual(habit.streak(on: Cal.add(days: 6, to: startMonday)), 1) // sunday (DUE)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startMonday)), 0) // monday
   }
   
   func testSpecifificWeekdayStreakLabel() {
      let today = Date().weekdayInt
      let startDate = Cal.getLast(weekday: Weekday(today))
      habit.updateStartDate(to: startDate)
      let specificWeekdays = [Weekday(Cal.add(days: 1, to: Date()))]
      habit.changeFrequency(to: .specificWeekdays(specificWeekdays), on: startDate)
      
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startDate)
      
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      habit.markCompleted(on: startDate)
      XCTAssertEqual(vm.streakLabel()?.label, "1 day streak")
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      vm.currentDay = Cal.add(days: 1, to: startDate)
      XCTAssertEqual(vm.streakLabel()?.label, "2 day streak")
      
      vm.currentDay = Cal.add(days: 2, to: startDate)
      XCTAssertEqual(vm.streakLabel()?.label, "2 day streak")
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      XCTAssertEqual(vm.streakLabel()?.label, "3 day streak")
   }
   
}
