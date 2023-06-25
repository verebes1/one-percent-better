//
//  NotificationTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/24/23.
//

import XCTest
@testable import ___Better

final class NotificationTests: XCTestCase {
   
   let context = CoreDataManager.previews.mainContext
   var habit: Habit!
   var notif: SpecificTimeNotification!
   
   override func setUpWithError() throws {
      habit = try! Habit(context: context, name: "Cook")
      notif = SpecificTimeNotification(context: context, time: Date())
   }
   
   override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      let habits = Habit.habits(from: context)
      for habit in habits {
         context.delete(habit)
      }
      try context.save()
   }
   
   class MockOpenAI: OpenAIRequest {
      func query(prompt: String) async throws -> String {
         try await Task.sleep(for: .milliseconds(Int.random(in: 1 ... 30 )))
         return "Test notification"
      }
   }
   
   func testAINotificationsRequest() async throws {
      let mockAI = MockOpenAI()
      notif.openAIDelegate = mockAI
      
//      let notifStrings = try await notif.getAINotifications(10)
//      XCTAssertEqual(notifStrings.count, 10)
   }
   
   func testParseGPTAnswerIntoArray() throws {
      let jsonNotifs = """
      {
        "notifications": [
          "Time to spill the tea, journal awaits!",
          "Hey, wordsmith! Journaling time, pronto.",
          "Did you misplace your thoughts? Journal them!",
          "Your journal is missing you, come back!",
          "Journaling: the best therapy. Get writing!",
          "Warning: neglecting your journal is illegal.",
          "Your thoughts called—they want you to journal.",
          "No journal, no peace. Get writing!",
          "Journaling is the new black. Get fashionable!",
          "You can't hide from your feelings, journal them!"
        ]
      }
      """
      
      let parsedAnswers = notif.parseGPTAnswerIntoArray(jsonNotifs)
      let correctAnswer = ["Time to spill the tea, journal awaits!", "Hey, wordsmith! Journaling time, pronto.", "Did you misplace your thoughts? Journal them!", "Your journal is missing you, come back!", "Journaling: the best therapy. Get writing!", "Warning: neglecting your journal is illegal.", "Your thoughts called—they want you to journal.", "No journal, no peace. Get writing!", "Journaling is the new black. Get fashionable!", "You can\'t hide from your feelings, journal them!"]
      XCTAssertEqual(parsedAnswers, correctAnswer)
   }
   
   func testParseGPTAnswerIntoArray2() {
      var jsonNotifs = """
      {
        "wrong_array_name": [
          "Time to spill the tea, journal awaits!",
          "Hey, wordsmith! Journaling time, pronto."
        ]
      }
      """
      let parsedAnswers = notif.parseGPTAnswerIntoArray(jsonNotifs)
      XCTAssertNil(parsedAnswers)
      
      jsonNotifs = """
      {
        "notifications": [
          "Time to spill the tea, journal awaits!",
          "Hey, wordsmith! Journaling time, pronto."
      }
      """
      let malformed = notif.parseGPTAnswerIntoArray(jsonNotifs)
      XCTAssertNil(malformed)
   }
}
