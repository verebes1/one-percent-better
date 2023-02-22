//
//  XTimesPerWeekTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 2/7/23.
//

import XCTest
@testable import ___Better

final class XTimesPerWeekTests: XCTestCase {
   
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
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      XCTAssertFalse(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0)
      
      habit.markCompleted(on: startSunday)
      XCTAssertTrue(habit.wasCompleted(on: startSunday))
      XCTAssertEqual(habit.percentCompleted(on: startSunday), 0.33, accuracy: 0.01)
   }
   
   /// Test if `wasCompletedThisWeek` works.
   /// Test that you can ask for any day of the week and get the same answer
   func testCompletedOn2() {
      let startSunday = df.date(from: "01-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .saturday), on: startSunday)
      
      for i in 0 ..< 7 {
         XCTAssertFalse(habit.wasCompletedThisWeek(on: Cal.add(days: i, to: startSunday)))
      }
      habit.markCompleted(on: startSunday)
      for i in 0 ..< 7 {
         XCTAssertFalse(habit.wasCompletedThisWeek(on: Cal.add(days: i, to: startSunday)))
      }
      habit.markCompleted(on: Cal.add(days: 1, to: startSunday))
      for i in 0 ..< 7 {
         XCTAssertFalse(habit.wasCompletedThisWeek(on: Cal.add(days: i, to: startSunday)))
      }
      habit.markCompleted(on: Cal.add(days: 2, to: startSunday))
      for i in 0 ..< 7 {
         XCTAssertTrue(habit.wasCompletedThisWeek(on: Cal.add(days: i, to: startSunday)))
      }
   }
   
   /// Test `wasCompletedThisWeek` works if your start date is tuesday, and you reset every monday, and you complete it your first week
   func testCompletedOn3() {
      let startTuesday = df.date(from: "12-6-2022")!
      habit.updateStartDate(to: startTuesday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .monday), on: startTuesday)
      
      XCTAssertFalse(habit.wasCompletedThisWeek(on: startTuesday))
      habit.markCompleted(on: startTuesday)
      habit.markCompleted(on: Cal.add(days: 1, to: startTuesday))
      habit.markCompleted(on: Cal.add(days: 2, to: startTuesday))
      XCTAssertTrue(habit.wasCompletedThisWeek(on: startTuesday))
   }
   
   func testTimesCompletedThisWeek() {
      let startSunday = df.date(from: "2-12-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      let monday = df.date(from: "2-20-2023")!
      let sunday = Cal.add(days: -1, to: monday)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday), 0)
      
      habit.markCompleted(on: sunday)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday), 1)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: 1, to: startSunday)), 1)
      
      habit.markCompleted(on: Cal.add(days: -1, to: sunday))
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday), 2)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: 1, to: startSunday)), 2)
   }
   
   func testTimesCompletedThisWeekUpTo() {
      let startSunday = df.date(from: "2-12-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      let monday = df.date(from: "2-20-2023")!
      let sunday = Cal.add(days: -1, to: monday)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday, upTo: true), 0)
      
      habit.markCompleted(on: sunday)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday, upTo: true), 1)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: 1, to: startSunday), upTo: true), 0)
      
      habit.markCompleted(on: Cal.add(days: -1, to: sunday))
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday, upTo: true), 2)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: -1, to: sunday), upTo: true), 1)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: 1, to: startSunday), upTo: true), 0)
                     
      habit.markCompleted(on: Cal.add(days: 1, to: startSunday))
      XCTAssertEqual(habit.timesCompletedThisWeek(on: monday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: sunday, upTo: true), 3)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: -1, to: sunday), upTo: true), 2)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: startSunday, upTo: true), 0)
      XCTAssertEqual(habit.timesCompletedThisWeek(on: Cal.add(days: 1, to: startSunday), upTo: true), 1)
   }
   
   // MARK: Is Due On Tests
   
   /// Test that the habit is only due on the reset day
   func testIsDue() {
      let startSunday = df.date(from: "1-29-2023")!
      habit.updateStartDate(to: startSunday)
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: .sunday), on: startSunday)
      
      XCTAssertTrue(habit.isDue(on: startSunday))
      
      for i in 1 ..< 7 {
         let day = Cal.add(days: i, to: startSunday)
         XCTAssertFalse(habit.isDue(on: day))
      }
      
      let nextSunday = Cal.add(days: 7, to: startSunday)
      XCTAssertTrue(habit.isDue(on: nextSunday))
   }
   
   // MARK: Streak Tests
   
   func testStreak() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 1, resetDay: .tuesday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 1)
      habit.markCompleted(on: Cal.add(days: 7, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 7, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 8, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 9, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 10, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 11, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 12, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 13, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 14, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 15, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 16, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 17, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 18, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 19, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 20, to: startWednesday)), 2)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 21, to: startWednesday)), 0)
      XCTAssertEqual(habit.streak(on: Cal.add(days: 22, to: startWednesday)), 0)
   }
   
   func testStreak2() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .saturday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      habit.markCompleted(on: Cal.add(days: 1, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
      
      let sundayFollowingStartWednesday = Cal.add(days: 4, to: startWednesday)
      XCTAssertEqual(habit.streak(on: sundayFollowingStartWednesday), 1)
   }
   
   func testStreak3() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .thursday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
   }
   
   func testStreak4() {
      let startWednesday = df.date(from: "12-7-2022")!
      habit.updateStartDate(to: startWednesday)
      habit.changeFrequency(to: .timesPerWeek(times: 2, resetDay: .friday), on: startWednesday)
      
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      
      habit.markCompleted(on: startWednesday)
      XCTAssertEqual(habit.streak(on: startWednesday), 0)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startWednesday))
      XCTAssertEqual(habit.streak(on: Cal.add(days: 1, to: startWednesday)), 1)
   }
   
   func testStreakLabel() {
      let today = Date().weekdayInt
      let startDate = Cal.getLast(weekday: Weekday(today))
      habit.updateStartDate(to: startDate)
      let resetDay = (today + 3) % 7
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)), on: startDate)
      
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startDate)
      
      XCTAssertEqual(vm.streakLabel().0, "No streak")
      habit.markCompleted(on: startDate)
      XCTAssertEqual(vm.streakLabel().0, "No streak")
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      vm.currentDay = Cal.add(days: 1, to: startDate)
      XCTAssertEqual(vm.streakLabel().0, "No streak")
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      vm.currentDay = Cal.add(days: 2, to: startDate)
      XCTAssertEqual(vm.streakLabel().0, "1 week streak")
   }
   
   func testStreakLabel2() {
      let today = Date().weekdayInt
      let backOneWeek = Cal.getLast(weekday: Weekday(today))
      let backTwoWeeks = Cal.getLast(weekday: Weekday(today), from: backOneWeek)
      let backThreeWeeks = Cal.getLast(weekday: Weekday(today), from: backTwoWeeks)
      let startDate = backThreeWeeks
      habit.updateStartDate(to: startDate)
      let resetDay = (today + 3) % 7
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)), on: startDate)
      
      let vm = HabitRowViewModel(moc: context, habit: habit, currentDay: startDate)
      
      XCTAssertEqual(vm.streakLabel().0, "No streak")
      habit.markCompleted(on: startDate)
      XCTAssertEqual(vm.streakLabel().0, "No streak")
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      vm.currentDay = Cal.add(days: 1, to: startDate)
      XCTAssertEqual(vm.streakLabel().0, "No streak")
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      vm.currentDay = Cal.add(days: 2, to: startDate)
      XCTAssertEqual(vm.streakLabel().0, "1 week streak")
      
      vm.currentDay = Cal.add(days: 7, to: startDate)
      XCTAssertEqual(vm.streakLabel().0, "1 week streak")
   }
   
   // MARK: Improvement Score Tests
   
   func testImprovementScore() {
      let today = Date().weekdayInt
      let startDate = Cal.getLast(weekday: Weekday(today)!)
      habit.updateStartDate(to: startDate)
      let resetDay = (today + 3) % 7
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)!), on: startDate)
      
      // 0 for start date, and 0 for first week failed
      XCTAssertEqual(habit.improvementTracker!.scores, [0, 0])
      
      habit.markCompleted(on: startDate)
      XCTAssertEqual(habit.improvementTracker!.scores[0], 1, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.scores[1], 2.01, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.scores[2], 3.03, accuracy: 0.01)
   }
   
   func testImprovementScore2() {
      let today = Date()
      let resetDay = (today.weekdayInt + 3) % 7
      habit.changeFrequency(to: .timesPerWeek(times: 3, resetDay: Weekday(resetDay)!), on: today)
      
      XCTAssertEqual(habit.improvementTracker?.score(on: today), 0)

      let startDate = Cal.getLast(weekday: Weekday(today.weekdayInt)!)
      habit.updateStartDate(to: startDate)
      XCTAssertEqual(habit.improvementTracker!.scores, [0, 0])
      
      habit.markCompleted(on: Cal.add(days: 1, to: startDate))
      XCTAssertEqual(habit.improvementTracker!.scores, [0, 1, 0])
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 0.33, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 2, to: startDate))
      // [0.0, 1.0, 2.01, 1.49]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 1.49, accuracy: 0.01)
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 0.66, accuracy: 0.01)
      
      
      habit.markCompleted(on: Cal.add(days: 3, to: startDate))
      // [0.0, 1.0, 2.01, 3.03]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
      XCTAssertEqual(habit.percentCompleted(on: Cal.add(days: 3, to: startDate)), 1.0)
      
      habit.markCompleted(on: Cal.add(days: 5, to: startDate))
      // [0.0, 1.0, 2.01, 3.03, 4.06]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 4.06, accuracy: 0.01)
      
      habit.markCompleted(on: Cal.add(days: 6, to: startDate))
      // [0.0, 1.0, 2.01, 3.03, 4.96]
      XCTAssertEqual(habit.improvementTracker!.scores[0], 0)
      XCTAssertEqual(habit.improvementTracker!.scores[1], 1)
      XCTAssertEqual(habit.improvementTracker!.scores[2], 2.01, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[3], 3.03, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[4], 4.06, accuracy: 0.01)
      XCTAssertEqual(habit.improvementTracker!.scores[5], 5.10, accuracy: 0.01)
   }
}
