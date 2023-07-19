//
//  NotificationGeneratorTests.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/24/23.
//

import XCTest
@testable import One_Percent_Better

final class NotificationGeneratorTests: XCTestCase {
   
   let context = CoreDataManager.previews.mainContext
   var habit: Habit!
   var notif: SpecificTimeNotification!
   var notificationGenerator: NotificationGenerator!
   
   override func setUpWithError() throws {
      habit = try! Habit(context: context, name: "Cook")
      notificationGenerator = NotificationGenerator()
      notificationGenerator.habitName = habit.name
   }
   
   override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      let habits = Habit.habits(from: context)
      for habit in habits {
         context.delete(habit)
      }
      try context.save()
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
      
      let parsedAnswers = notificationGenerator.parseGPTAnswerIntoArray(jsonNotifs)
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
      let parsedAnswers = notificationGenerator.parseGPTAnswerIntoArray(jsonNotifs)
      XCTAssertNil(parsedAnswers)
      
      jsonNotifs = """
      {
        "notifications": [
          "Time to spill the tea, journal awaits!",
          "Hey, wordsmith! Journaling time, pronto."
      }
      """
      let malformed = notificationGenerator.parseGPTAnswerIntoArray(jsonNotifs)
      XCTAssertNil(malformed)
   }
}
