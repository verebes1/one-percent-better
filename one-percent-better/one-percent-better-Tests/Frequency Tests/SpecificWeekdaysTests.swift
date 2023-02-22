//
//  SpecificWeekdaysTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/21/23.
//

import XCTest
@testable import ___Better

final class SpecificWeekdaysTests: XCTestCase {

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
   
   // MARK: Completed On Tests
   
   func testCompletedOn() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .specificWeekdays([.monday, .wednesday, .friday]), on: startSunday)
      
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertTrue(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 1.0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startSunday))
      XCTAssertTrue(habit.wasCompleted(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 1, to: startSunday)), 1.0)
      
      XCTAssertFalse(habit.wasCompleted(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 2, to: startSunday)), 0.0)
   }
   
   // MARK: Is Due On Tests
   
   /// Test that the habit is only due on the reset day
   func testIsDue() {
      let startSunday = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .specificWeekdays([.monday, .tuesday, .wednesday]), on: startSunday)
      
      XCTAssertFalse(habit.isDue(on: startSunday))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 3, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 5, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 6, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 7, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 8, to: startSunday)))
   }
   
   func testIsDue2() {
      let startSunday = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .specificWeekdays([.sunday, .friday, .saturday]), on: startSunday)
      
      XCTAssertTrue(habit.isDue(on: startSunday))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 1, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 2, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 3, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 4, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 5, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 6, to: startSunday)))
      XCTAssertTrue(habit.isDue(on: Cal.add(days: 7, to: startSunday)))
      XCTAssertFalse(habit.isDue(on: Cal.add(days: 8, to: startSunday)))
   }
   
   // MARK: Streak Tests
   
   func testStreak() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .specificWeekdays([.wednesday, .thursday]), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 1)
      let thursday = Cal.add(days: 1, to: startWednesday)
      XCTAssertEqual(habit.streak(on: thursday), 1)
      
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
   
//   
//   func testStreak2() {
//      let startWednesday = df.date(from: "12-7-2022")!
//      habit.updateStartDate(to: startWednesday)
//      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .saturday), on: startWednesday)
//      
//      XCTAssertEqual(habit.streak(on: startWednesday), 0)
//      habit.markCompleted(on: startWednesday)
//      XCTAssertEqual(habit.streak(on: startWednesday), 0)
//      habit.markCompleted(on: Cal.add(days: 1, to: startWednesday))
//      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
//      
//      let sundayFollowingStartWednesday = Cal.add(days: 4, to: startWednesday)
//      XCTAssertEqual(habit.streak(on: sundayFollowingStartWednesday), 1)
//   }
//   
//   func testStreak3() {
//      let startWednesday = df.date(from: "12-7-2022")!
//      habit.updateStartDate(to: startWednesday)
//      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .thursday), on: startWednesday)
//      
//      XCTAssertEqual(habit.streak(on: startWednesday), 0)
//      
//      habit.markCompleted(on: startWednesday)
//      XCTAssertEqual(habit.streak(on: startWednesday), 0)
//      
//      habit.markCompleted(on: Cal.add(days: 1, to: startWednesday))
//      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
//      
//      habit.markCompleted(on: Cal.add(days: 2, to: startWednesday))
//      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
//   }
//   
//   func testStreak4() {
//      let startWednesday = df.date(from: "12-7-2022")!
//      habit.updateStartDate(to: startWednesday)
//      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .friday), on: startWednesday)
//      
//      XCTAssertEqual(habit.streak(on: startWednesday), 0)
//      
//      habit.markCompleted(on: startWednesday)
//      XCTAssertEqual(habit.streak(on: startWednesday), 0)
//      
//      habit.markCompleted(on: Cal.add(days: 1, to: startWednesday))
//      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
//      
//      habit.markCompleted(on: Cal.add(days: 2, to: startWednesday))
//      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
//   }
//   
//   func testStreakLabel() {
//      let today = Date().weekdayInt
//      let startDate = Cal.getLast(weekday: Weekday(today)!)
//      habit.updateStartDate(to: startDate)
//      let resetDay = (today + 3) % 7
//      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)!), on: startDate)
//      
//      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startDate)
//      
//      XCTAssertEqual(vm.streakLabel().0, "No streak")
//      habit.markCompleted(on: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "No streak")
//      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
//      vm.currentDay = Cal.add(days: 1, to: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "No streak")
//      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
//      vm.currentDay = Cal.add(days: 2, to: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "1 week streak")
//   }
//   
//   func testStreakLabel2() {
//      let today = Date().weekdayInt
//      let backOneWeek = Cal.getLast(weekday: Weekday(today)!)
//      let backTwoWeeks = Cal.getLast(weekday: Weekday(today)!, from: backOneWeek)
//      let backThreeWeeks = Cal.getLast(weekday: Weekday(today)!, from: backTwoWeeks)
//      let startDate = backThreeWeeks
//      habit.updateStartDate(to: startDate)
//      let resetDay = (today + 3) % 7
//      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)!), on: startDate)
//      
//      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startDate)
//      
//      XCTAssertEqual(vm.streakLabel().0, "No streak")
//      habit.markCompleted(on: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "No streak")
//      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
//      vm.currentDay = Cal.add(days: 1, to: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "No streak")
//      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
//      vm.currentDay = Cal.add(days: 2, to: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "1 week streak")
//      
//      vm.currentDay = Cal.add(days: 7, to: startDate)
//      XCTAssertEqual(vm.streakLabel().0, "1 week streak")
//   }
//   
//   // MARK: Improvement Score Tests
//   
//   func testImprovementScore() {
//      let today = Date().weekdayInt
//      let startDate = Cal.getLast(weekday: Weekday(today)!)
//      habit.updateStartDate(to: startDate)
//      let resetDay = (today + 3) % 7
//      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)!), on: startDate)
//      
//      // 0 for start date, and 0 for first week failed
//      XCTAssertEqual(habit.improvementTracker!.scores, [0, 0])
//      
//      habit.markCompleted(on: startDate)
//      XCTAssertEqual(habit.improvementTracker!.scores[0], 1, accuracy: 0.01)
//      
//      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
//      XCTAssertEqual(habit.improvementTracker!.scores[1], 2.01, accuracy: 0.01)
//      
//      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
//      XCTAssertEqual(habit.improvementTracker!.scores[2], 3.03, accuracy: 0.01)
//   }
//   
//   func testImprovementScore2() {
//      let today = Date()
//      let resetDay = (today.weekdayInt + 3) % 7
//      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)!), on: today)
//      
//      XCTAssertEqual(habit.improvementTracker?.score(on: today), 0)
//
//      let startDate = Cal.getLast(weekday: Weekday(today.weekdayInt)!)
//      habit.updateStartDate(to: startDate)
//      XCTAssertEqual(habit.improvementTracker!.scores, [0, 0])
//      
//      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
//      XCTAssertEqual(habit.improvementTracker!.scores, [0, 1, 0])
//      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 0.33, accuracy: 0.01)
//      
//      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
//      // [0.0, 1.0, 2.01, 1.49]
//      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
//      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
//      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[3], 1.49, accuracy: 0.01)
//      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 0.66, accuracy: 0.01)
//      
//      
//      habit.markCompleted(on: Cal.add(days: 3, to: startDate))
//      // [0.0, 1.0, 2.01, 3.03]
//      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
//      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
//      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
//      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 1.0)
//      
//      habit.markCompleted(on: Cal.add(days: 5, to: startDate))
//      // [0.0, 1.0, 2.01, 3.03, 4.06]
//      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
//      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
//      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[4], 4.06, accuracy: 0.01)
//      
//      habit.markCompleted(on: Cal.add(days: 6, to: startDate))
//      // [0.0, 1.0, 2.01, 3.03, 4.96]
//      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
//      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
//      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[4], 4.06, accuracy: 0.01)
//      XCTAssertEqual(habit.improvementTracker!.scores[5], 5.10, accuracy: 0.01)
//   }

}