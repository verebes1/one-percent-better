//
//  MockNotificationGenerator.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/28/23.
//

import Foundation

class MockNotificationGenerator: NotificationGeneratorDelegate {
   func generateNotifications(habit: Habit) async throws -> [String] {
      try await Task.sleep(for: .milliseconds(Int.random(in: 1 ... 30 )))
      let notifs = Array(repeating: "Time to spill the tea, journal awaits!", count: NotificationManager.MAX_NOTIFS / 2)
      return notifs
   }
}
