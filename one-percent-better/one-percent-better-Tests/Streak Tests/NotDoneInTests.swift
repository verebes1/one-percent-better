//
//  NotDoneInTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 5/15/23.
//

import XCTest
import CoreData
@testable import ___Better

final class NotDoneInTests: XCTestCase {
   
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
   
   func testOneTimePerWeek() throws {
      
      let startWednesday = df.date(from: "12-7-2022")!
      
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startWednesday)
      
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday), on: startWednesday)
      
      // X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // -   -   -   -   -   -   -   -
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      XCTAssertNotNil(habit.notDoneInDays(on: startWednesday))
      
      // X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   -   -   -   -   -   -   -
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: startWednesday), 0)
      
      //     X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   -   -   -   -   -   -   -
      vm.currentDay = df.date(from: "12-8-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 1)
      
      //     X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   C   -   -   -   -   -   -
      habit.markCompleted(on: df.date(from: "12-8-2022")!)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 0)
      
      //         X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   C   -   -   -   -   -   -
      vm.currentDay = df.date(from: "12-9-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 1)
      
      //             X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   C   -   -   -   -   -   -
      vm.currentDay = df.date(from: "12-10-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 2)
      
      //                         X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   C   -   -   -   -   -   -
      vm.currentDay = df.date(from: "12-13-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 5)
      
      //                             X
      // 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
      // C   C   -   -   -   -   -   -
      vm.currentDay = df.date(from: "12-14-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 6)
   }
   
   func testOneTimePerWeek2() throws {
      let startWednesday = df.date(from: "12-7-2022")!
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startWednesday)
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday), on: startWednesday)
      
      // Never done
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      XCTAssertNil(habit.notDoneInDays(on: startWednesday))
      
      // Done once
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: startWednesday), 0)
      
      // Next week (should still have streak)
      vm.currentDay = df.date(from: "12-14-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 7)
      
      // Next week (on the day before it changes, should still have streak)
      vm.currentDay = df.date(from: "12-18-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 11)
      
      // Next next week (on the day it changes, no longer have streak)
      vm.currentDay = df.date(from: "12-19-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("Not done in 12 days", .red))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 12)
      
      // Next next week (no longer have streak)
      vm.currentDay = df.date(from: "12-21-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("Not done in 14 days", .red))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 14)
   }
   
   func testTwoTimesPerWeek() throws {
      let startWednesday = df.date(from: "12-7-2022")!
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startWednesday)
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .sunday), on: startWednesday)
      
      // Never done
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      XCTAssertNil(habit.notDoneInDays(on: startWednesday))
      
      // Done once
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      XCTAssertEqual(habit.notDoneInDays(on: startWednesday), 0)
      
      // Done twice
      vm.currentDay = df.date(from: "12-8-2022")!
      habit.markCompleted(on: vm.currentDay)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 0)
      
      // Next week (should still have streak)
      vm.currentDay = df.date(from: "12-14-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 6)
      
      // Next week (on the day before it changes, should still have streak)
      vm.currentDay = df.date(from: "12-18-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 10)
      
      // Next next week (on the day it changes, no longer have streak)
      vm.currentDay = df.date(from: "12-19-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("Not done in 11 days", .red))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 11)
      
      // Next next week (no longer have streak)
      vm.currentDay = df.date(from: "12-21-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("Not done in 13 days", .red))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 13)
   }
   
   func testTwoTimesPerWeek2() throws {
      let startWednesday = df.date(from: "12-7-2022")!
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startWednesday)
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .sunday), on: startWednesday)
      
      // Never done
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      XCTAssertNil(habit.notDoneInDays(on: startWednesday))
      
      // Done once
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("No streak", StreakLabel.gray))
      XCTAssertEqual(habit.notDoneInDays(on: startWednesday), 0)
      
      // Done twice
      vm.currentDay = df.date(from: "12-8-2022")!
      habit.markCompleted(on: vm.currentDay)
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 0)
      
      // Next week (should still have streak)
      vm.currentDay = df.date(from: "12-14-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 6)
      
      // Next week (on the day before it changes, should still have streak)
      vm.currentDay = df.date(from: "12-18-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("1 week streak", .green))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 10)
      
      // Next next week (on the day it changes, no longer have streak)
      vm.currentDay = df.date(from: "12-19-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("Not done in 11 days", .red))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 11)
      
      // Next next week (no longer have streak)
      vm.currentDay = df.date(from: "12-21-2022")!
      XCTAssertEqual(vm.streakLabel(), StreakLabel("Not done in 13 days", .red))
      XCTAssertEqual(habit.notDoneInDays(on: vm.currentDay), 13)
   }
}
