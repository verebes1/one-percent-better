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
    let context = CoreDataManager.previews.mainContext
    var hlvm: HabitListViewModel!
    
//    var h0: Habit!
//    var h1: Habit!
//    var h2: Habit!
//    var h3: Habit!
//    var h4: Habit!
    
    override func setUpWithError() throws {
//        h0 = try Habit(context: context, name: "Habit 0")
//        h1 = try Habit(context: context, name: "Habit 1")
//        h2 = try Habit(context: context, name: "Habit 2")
//        h3 = try Habit(context: context, name: "Habit 3")
//        h4 = try Habit(context: context, name: "Habit 4")
        hlvm = HabitListViewModel(context)
    }
    
    override func tearDownWithError() throws {
        let habits = context.fetchArray(Habit.self)
        habits.forEach { context.delete($0) }
        try context.save()
    }
    
    func verify(order: [Habit]) {
        let habits = context.fetchArray(Habit.self)
        XCTAssertEqual(habits.count, order.count)
        for (index, habit) in habits.enumerated() {
            XCTAssertEqual(habit, order[index])
        }
    }
    
    func verify(remaining: Set<Habit>) {
        let habits = context.fetchArray(Habit.self)
        let remainingFromContext = Set(habits.map { $0.id })
        let remainingArg = Set(remaining.map { $0.id })
        XCTAssertEqual(remainingFromContext, remainingArg)
    }
    
    
    /*
     
     Reordering
     
     Parameters:
     - Number of habits
         - Selected day
             - One day vs spans multiple days and habits have different start dates)
         - Section
             - One section vs multiple sections
         - Frequency
             - One frequency vs habit changing frequency
     */
    
    func test2Habits() throws {
        let h0 = try Habit(context: context, name: "Habit 0")
        let h1 = try Habit(context: context, name: "Habit 1")
        
        // 0, 1
        verify(order: [h0, h1])
        
        // x = old position, n = new position
        // 0:  x0 |
        // 1:  1  |  1
        // 2:     | n0
        hlvm.sectionMove(from: IndexSet(integer: 0), to: 2, on: Date(), for: .dueToday)
        verify(order: [h1, h0])
        
        // 0:  x1 |
        // 1:  0  |  0
        // 2:     | n1
        hlvm.sectionMove(from: IndexSet(integer: 0), to: 2, on: Date(), for: .dueToday)
        verify(order: [h0, h1])
        
        // 0:     | n1
        // 0:  0  |  0
        // 1:  x1 |
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
        verify(order: [h1, h0])
        
        // 0:     | n0
        // 0:  1  |  1
        // 1:  x0 |
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
        verify(order: [h0, h1])
    }
    
    func test3Habits() throws {
        let h0 = try Habit(context: context, name: "Habit 0")
        let h1 = try Habit(context: context, name: "Habit 1")
        let h2 = try Habit(context: context, name: "Habit 2")
        
        // 0, 1, 2
        verify(order: [h0, h1, h2])
        
        // x = old position, n = new position
        // 0:  x0 |
        // 1:  1  |  1
        // 2:  2  | n0
        // 2:     |  2
        hlvm.sectionMove(from: IndexSet(integer: 0), to: 2, on: Date(), for: .dueToday)
        verify(order: [h1, h0, h2])
        
        // 0:  x1 |
        // 1:  0  |  0
        // 2:  2  |  2
        // 3:     |  n1
        hlvm.sectionMove(from: IndexSet(integer: 0), to: 3, on: Date(), for: .dueToday)
        verify(order: [h0, h2, h1])
        
        // 0:  0  |  0
        // 1:  x2 |
        // 2:  1  |  1
        // 3:     |  n2
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 3, on: Date(), for: .dueToday)
        verify(order: [h0, h1, h2])
        
        // 0:     | n1
        // 0:  0  |  0
        // 1:  x1 |
        // 2:  2  |  2
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
        verify(order: [h1, h0, h2])
        
        // 0:  1  |  1
        // 1:     | n2
        // 1:  0  |  0
        // 2:  x2 |
        hlvm.sectionMove(from: IndexSet(integer: 2), to: 1, on: Date(), for: .dueToday)
        verify(order: [h1, h2, h0])
        
        // 0:     | n0
        // 0:  1  |  1
        // 1:  2  |  2
        // 2:  x0 |
        hlvm.sectionMove(from: IndexSet(integer: 2), to: 0, on: Date(), for: .dueToday)
        verify(order: [h0, h1, h2])
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
                print("\(i) -> \(j)")
            }
        }
        
        // Moving down
        for i in stride(from: n - 1, through: 1, by: -1) {
            for j in stride(from: i - 1, through: 0, by: -1) {
                let moveTuple = (from: IndexSet(integer: i), to: j)
                perms.append(moveTuple)
                print("\(i) -> \(j)")
            }
        }
        print(perms)
        return perms
    }
    
    
//    func testReorderAllDaily() throws {
//        verify(order: [0, 1, 2, 3, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
//        verify(order: [1, 0, 2, 3, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 4), to: 0, on: Date(), for: .dueToday)
//        verify(order: [4, 1, 0, 2, 3])
//
//        hlvm.sectionMove(from: IndexSet(integer: 4), to: 0, on: Date(), for: .dueToday)
//        verify(order: [3, 4, 1, 0, 2])
//    }
//
//    func testReorderAllWeekly() throws {
//        h0.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h1.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
//
//        verify(order: [0, 1, 2, 3, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueThisWeek)
//        verify(order: [1, 0, 2, 3, 4])
//    }
//
//    func testReorderDailyAndWeekly() throws {
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
//        verify(order: [0, 1, 2, 3, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
//        verify(order: [1, 0, 2, 3, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueThisWeek)
//        verify(order: [1, 0, 3, 2, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueThisWeek)
//        verify(order: [1, 0, 2, 3, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 2), to: 1, on: Date(), for: .dueThisWeek)
//        verify(order: [1, 0, 2, 4, 3])
//
//        hlvm.sectionMove(from: IndexSet(integer: 2), to: 0, on: Date(), for: .dueThisWeek)
//        verify(order: [1, 0, 3, 2, 4])
//
//        hlvm.sectionMove(from: IndexSet(integer: 2), to: 0, on: Date(), for: .dueThisWeek)
//        verify(order: [1, 0, 4, 3, 2])
//    }
//
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
