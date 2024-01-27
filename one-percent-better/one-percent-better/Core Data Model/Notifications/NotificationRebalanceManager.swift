//
//  NotificationRebalanceManager.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/15/23.
//

import Foundation
import Combine

/// This actor controls the task which rebalances the habit notifications.
/// Only one rebalance task should be running at one time, and subsequent
/// rebalance requests will cancel the current rebalance task and start a new one.
actor NotificationRebalanceManager {
    typealias RebalanceWork = () async throws -> ()
    var work: RebalanceWork
    
    private var currentTask: Task<Void, Never>?
    private var observer: PassthroughSubject<Bool, Never>?
    
    var isRebalancing: Bool {
        currentTask != nil
    }
    
    init(work: @escaping RebalanceWork, observer: PassthroughSubject<Bool, Never>? = nil) {
        self.work = work
        self.observer = observer
    }
    
    func requestRebalance() async {
        await cancelRebalance()
        observer?.send(true)
        currentTask = Task {
            do {
                try await work()
            } catch is CancellationError {
                // Handle cancellation if necessary
            } catch {
                print("Rebalance error: \(error.localizedDescription)")
            }
            currentTask = nil
            observer?.send(false)
        }
    }

    func cancelRebalance() async {
        if let task = currentTask {
            task.cancel()
            await task.value
        }
    }
}


