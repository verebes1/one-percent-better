//
//  NotificationRebalanceManagerTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 10/15/23.
//

import XCTest
@testable import One_Percent_Better

/// Test the rebalance requester works properly
/// Only one rebalance should be happening at any one time
/// Multiple rebalance requests can happen while a rebalance is occuring
/// Whenever a rebalance request happens, the rebalance task must be cancelled and start over
/// Only if there is no current rebalance task running do we start a new rebalance task
final class NotificationRebalanceManagerTests: XCTestCase {
    
    var actor: NotificationRebalanceManager!
    var synchronizationActor: SynchronizationActor!
    var workExecutedCount: Int!
    
    override func setUp() {
        super.setUp()
        synchronizationActor = SynchronizationActor()
        actor = NotificationRebalanceManager { [weak self] in
            await self?.synchronizationActor.workStarted()
            try await self?.synchronizationActor.waitToContinue()
            await self?.synchronizationActor.workCompleted()
        }
    }
    
    override func tearDown() {
        actor = nil
        synchronizationActor = nil
        workExecutedCount = nil
        super.tearDown()
    }
    
    func testRebalanceRequest() async {
        // Request a rebalance
        await actor.requestRebalance()
        
        // Wait for the rebalance to finish
        await actor.waitForFinish()
        
        // Ensure the work was executed
        XCTAssertEqual(workExecutedCount, 1)
    }
    
    func testRebalanceCancellation() async throws {
        
        let exp = expectation(description: "Wait for cancellation to complete")
        
        Task {
            await actor.requestRebalance()
        }
        
        Task {
            await synchronizationActor.waitForWorkToStart()
            await actor.cancelRebalance()
            await synchronizationActor.workCanContinue()
            exp.fulfill()
        }
        
        await fulfillment(of: [exp], timeout: 200)
        
        // Check that work never completed
        let result = await synchronizationActor.didWorkComplete()
        XCTAssertFalse(result)
    }
    
//    func testMultipleRebalanceRequests() async throws {
//        // Start multiple rebalances almost immediately after each other
//        for _ in 1...5 {
//            await actor.requestRebalance()
//            try await Task.sleep(for: .milliseconds(10))
//        }
//        
//        // Give some time for the work to complete
//        try await Task.sleep(for: .milliseconds(700))
//        
//        // Ensure the work was executed only once (the last request should have completed)
//        XCTAssertEqual(workExecutedCount, 1)
//    }
}

actor SynchronizationActor {
    private var workHasStarted: Bool = false
    private var canContinue: Bool = false
    private var workHasCompleted: Bool = false

    func workStarted() {
        workHasStarted = true
    }
    
    func waitToContinue() async throws {
        while !canContinue {
            try Task.checkCancellation()
            try await Task.sleep(for: .milliseconds(10))
        }
    }
    
    func workCanContinue() {
        canContinue = true
    }
    
    func waitForWorkToStart() async {
        while !workHasStarted {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    func workCompleted() {
        workHasCompleted = true
    }

    func didWorkComplete() -> Bool {
        return workHasCompleted
    }
}
