//
//  HabitListTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 8/11/23.
//

import XCTest
@testable import One_Percent_Better

final class HabitListTests: XCTestCase {
    
    let context = CoreDataManager.previews.mainContext
    var hlvm: HabitListViewModel!
    
    var h0: Habit!
    var h1: Habit!
    var h2: Habit!
    var h3: Habit!
    var h4: Habit!
    
    override func setUpWithError() throws {
        h0 = try Habit(context: context, name: "Habit 0")
        h1 = try Habit(context: context, name: "Habit 1")
        h2 = try Habit(context: context, name: "Habit 2")
        h3 = try Habit(context: context, name: "Habit 3")
        h4 = try Habit(context: context, name: "Habit 4")
        hlvm = HabitListViewModel(context)
    }
    
    override func tearDownWithError() throws {
        let habits = Habit.habits(from: context)
        habits.forEach { context.delete($0) }
        try context.save()
    }
    
    func verify(order: [Int]) {
        XCTAssertEqual(h0.orderIndex, order.firstIndex(of: 0)!)
        XCTAssertEqual(h1.orderIndex, order.firstIndex(of: 1)!)
        XCTAssertEqual(h2.orderIndex, order.firstIndex(of: 2)!)
        XCTAssertEqual(h3.orderIndex, order.firstIndex(of: 3)!)
        XCTAssertEqual(h4.orderIndex, order.firstIndex(of: 4)!)
    }
    
    func verify(remaining: Set<Habit>) {
        let habits = Habit.habits(from: context)
        let remainingFromContext = Set(habits.map { $0.id })
        let remainingArg = Set(remaining.map { $0.id })
        XCTAssertEqual(remainingFromContext, remainingArg)
    }
    
    func testReorderAllDaily() throws {
        verify(order: [0, 1, 2, 3, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
        verify(order: [1, 0, 2, 3, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 4), to: 0, on: Date(), for: .dueToday)
        verify(order: [4, 1, 0, 2, 3])
        
        hlvm.sectionMove(from: IndexSet(integer: 4), to: 0, on: Date(), for: .dueToday)
        verify(order: [3, 4, 1, 0, 2])
    }
    
    func testReorderAllWeekly() throws {
        h0.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h1.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        
        verify(order: [0, 1, 2, 3, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueThisWeek)
        verify(order: [1, 0, 2, 3, 4])
    }
    
    func testReorderDailyAndWeekly() throws {
        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        
        // daily
        // 0
        // 1
        //
        // weekly
        // 2
        // 3
        // 4
        
        verify(order: [0, 1, 2, 3, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueToday)
        verify(order: [1, 0, 2, 3, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueThisWeek)
        verify(order: [1, 0, 3, 2, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 1), to: 0, on: Date(), for: .dueThisWeek)
        verify(order: [1, 0, 2, 3, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 2), to: 1, on: Date(), for: .dueThisWeek)
        verify(order: [1, 0, 2, 4, 3])
        
        hlvm.sectionMove(from: IndexSet(integer: 2), to: 0, on: Date(), for: .dueThisWeek)
        verify(order: [1, 0, 3, 2, 4])
        
        hlvm.sectionMove(from: IndexSet(integer: 2), to: 0, on: Date(), for: .dueThisWeek)
        verify(order: [1, 0, 4, 3, 2])
    }
    
    func testDeleteDaily() throws {
        verify(remaining: [h0, h1, h2, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
        verify(remaining: [h1, h2, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 2), on: Date(), for: .dueToday)
        verify(remaining: [h1, h2, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 1), on: Date(), for: .dueToday)
        verify(remaining: [h1, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
        verify(remaining: [h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
        verify(remaining: [])
    }
    
    func testDeleteWeekly() throws {
        h0.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h1.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        
        verify(remaining: [h0, h1, h2, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
        verify(remaining: [h1, h2, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 2), on: Date(), for: .dueThisWeek)
        verify(remaining: [h1, h2, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 1), on: Date(), for: .dueThisWeek)
        verify(remaining: [h1, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
        verify(remaining: [h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
        verify(remaining: [])
    }
    
    func testDeleteDailyAndWeekly() throws {
        h2.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h3.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        h4.updateFrequency(to: .timesPerWeek(times: 1, resetDay: .sunday))
        
        // daily
        // 0
        // 1
        //
        // weekly
        // 2
        // 3
        // 4
        
        verify(remaining: [h0, h1, h2, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
        verify(remaining: [h0, h1, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
        verify(remaining: [h1, h3, h4])
        
        hlvm.sectionDelete(from: IndexSet(integer: 1), on: Date(), for: .dueThisWeek)
        verify(remaining: [h1, h3])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueThisWeek)
        verify(remaining: [h1])
        
        hlvm.sectionDelete(from: IndexSet(integer: 0), on: Date(), for: .dueToday)
        verify(remaining: [])
    }
}
