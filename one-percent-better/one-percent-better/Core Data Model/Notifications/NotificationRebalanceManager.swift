//
//  NotificationRebalanceManager.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/15/23.
//

import Foundation

actor NotificationRebalanceManager {
    private var currentTask: Task<Void, Never>?
    typealias RebalanceWork = () async throws -> ()
    var work: RebalanceWork
    
    var isRebalancing: Bool {
        currentTask != nil
    }
    
    init(work: @escaping RebalanceWork) {
        self.work = work
    }
    
    func requestRebalance() async {
        await cancelCurrentTask()
        currentTask = Task {
            do {
                try await work()
            } catch is CancellationError {
                // Handle cancellation if necessary
            } catch {
                print("Rebalance error: \(error.localizedDescription)")
            }
            currentTask = nil
        }
    }
    
    func cancelRebalance() async {
        await cancelCurrentTask()
    }
    
    private func cancelCurrentTask() async {
        if let task = currentTask {
            task.cancel()
            await task.value
        }
    }
    
    func waitForFinish() async {
        if let task = currentTask {
            await task.value
        }
    }
}


