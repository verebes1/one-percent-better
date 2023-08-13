//
//  HabitListMoveDeleteTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 8/11/23.
//

import XCTest
@testable import One_Percent_Better

/// This class tests the reordering/deletion of habits in the habit list
final class HabitListMoveDeleteTests: XCTestCase {
    
    /*
     
     Reordering list parameters:
     - Number of habits
     - Selected day
         - One day vs spans multiple days and habits have different start dates)
     - Section
         - One section vs multiple sections
     - Frequency
         - One frequency vs habit changing frequency
     */
    
    let context = CoreDataManager.previews.mainContext
    var hlvm: HabitListViewModel!
    
    override func setUpWithError() throws {
        hlvm = HabitListViewModel(context)
    }
    
    override func tearDownWithError() throws {
        try removeAllHabits()
    }
    
    func removeAllHabits() throws {
        let habits = context.fetchArray(Habit.self)
        habits.forEach { context.delete($0) }
        try context.save()
    }
    
    func verify(order: [Habit]) {
        let habits = context.fetchArray(Habit.self)
        XCTAssertEqual(habits, order)
        
        for (index, habit) in habits.enumerated() {
            XCTAssertEqual(habit.orderIndex, index)
        }
    }
    
    func movePermutations(count n: Int) -> [(from: IndexSet, to: Int)] {
        var perms: [(from: IndexSet, to: Int)] = []
        // Moving up
        for i in 0 ..< n {
            // An item has to move up past itself and past the next item, hence starting at i + 2
            // An item can max move up past the last item n, hence max n + 1
            guard i + 2 < n + 1 else { continue }
            for j in i + 2 ..< n + 1 {
                let moveTuple = (from: IndexSet(integer: i), to: j)
                perms.append(moveTuple)
            }
        }
        
        // Moving down
        for i in stride(from: n - 1, through: 1, by: -1) {
            for j in stride(from: i - 1, through: 0, by: -1) {
                let moveTuple = (from: IndexSet(integer: i), to: j)
                perms.append(moveTuple)
            }
        }
        return perms
    }
    
    func createSectionList(count n: Int, section: HabitListSection) throws -> [Habit] {
        var sectionList: [Habit] = []
        for i in 0 ..< n {
            let habit = try Habit(context: context, name: "Habit \(i)")
            switch section {
            case .dueToday:
                break
            case .dueThisWeek:
                // Choose a reset day which is NOT today, so habits appear in due this week section
                let resetDay = Weekday((Date().weekdayInt + 3) % 7)
                habit.updateFrequency(to: .timesPerWeek(times: 1, resetDay: resetDay))
            }
            sectionList.append(habit)
        }
        return sectionList
    }
    
    func verifyAllReorderingPermutations(sectionList: [Habit], for section: HabitListSection) {
        var sectionList = sectionList
        for perm in movePermutations(count: sectionList.count) {
            sectionList.move(fromOffsets: perm.from, toOffset: perm.to)
            hlvm.move(from: perm.from, to: perm.to)
            verify(order: sectionList)
        }
    }
    
    func testReorderingHabits() throws {
        for section in HabitListSection.allCases {
            for i in 2 ... 6 {
                let sectionList = try createSectionList(count: i, section: section)
                verifyAllReorderingPermutations(sectionList: sectionList, for: section)
                try removeAllHabits()
            }
        }
    }
    
    func verify(remaining: Set<Habit>) {
        let habits = context.fetchArray(Habit.self)
        let remainingFromContext = Set(habits.map { $0.id })
        let remainingArg = Set(remaining.map { $0.id })
        XCTAssertEqual(remainingFromContext, remainingArg)
    }
    
//    func testDeleteDaily() throws {
//        verify(remaining: [h0, h1, h2, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
//        verify(remaining: [h1, h2, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 2), on: Date(), for: .dueToday)
//        verify(remaining: [h1, h2, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 1), on: Date(), for: .dueToday)
//        verify(remaining: [h1, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
//        verify(remaining: [h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
//        verify(remaining: [])
//    }
//
//    func testDeleteWeekly() throws {
//        h0.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h1.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//
//        verify(remaining: [h0, h1, h2, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h1, h2, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 2), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h1, h2, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 1), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h1, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
//        verify(remaining: [])
//    }
//
//    func testDeleteDailyAndWeekly() throws {
//        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//
//        // daily
//        // 0
//        // 1
//        //
//        // weekly
//        // 2
//        // 3
//        // 4
//
//        verify(remaining: [h0, h1, h2, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h0, h1, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
//        verify(remaining: [h1, h3, h4])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 1), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h1, h3])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
//        verify(remaining: [h1])
//
//        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
//        verify(remaining: [])
//    }
}
