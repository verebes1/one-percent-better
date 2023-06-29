//
//  NotificationGenerator.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/28/23.
//

import Foundation

protocol NotificationGeneratorDelegate {
   func generateNotifications() async throws -> [String]
}

class NotificationGenerator: NotificationGeneratorDelegate {
   
   let habit: Habit
   let chatGPT: ChatGPTDelegate
   
   init(habit: Habit, chatGPTDelegate: ChatGPTDelegate = OpenAI()) {
      self.habit = habit
      self.chatGPT = chatGPTDelegate
   }
   
   func notificationPrompt(n: Int, adjective: String) -> String {
      return """
             Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their habit named "\(habit.name.lowercased())".
             Requirements: For each notification, use between 10 and 60 characters. Return them as a JSON array named "notifications".
             """
   }
   
   func generateNotifications() async throws -> [String] {
      var notifs: [String] = []
      let adjectiveArray = ["creative": 7, "motivating": 5, "sassy": 5, "funny": 10, "funny Gen Z": 5]
      for (adjective, count) in adjectiveArray {
         if let someNotifs = try await getAINotifications(count, adjective: adjective) {
            notifs.append(contentsOf: someNotifs)
         }
      }
      if notifs.isEmpty {
         notifs = defaultNotifications()
      }
      return notifs
   }
   
   func defaultNotifications() -> [String] {
      let notifs: [String] = [
         "Time to XX! Consistency is key to success.",
         "Reminder: It's time to XX. Keep up the good work!",
         "Don't forget to XX today. Remember, small steps lead to big results.",
         "A friendly nudge: It's time to XX. You've got this!",
         "It's XX time! Stick with it, and you'll see progress in no time."
      ]
      return notifs.map { $0.replacingOccurrences(of: "XX", with: habit.name.lowercased()) }
   }
   
   /// Parse the ChatGPT json answer from the prompt into a Swift array
   /// - Parameter jsonString: The json answer
   /// - Returns: An array of the strings, nil if error parsing the json
   func parseGPTAnswerIntoArray(_ jsonString: String) -> [String]? {
      guard let data = jsonString.data(using: .utf8) else {
         print("Error converting ChatGPT JSON string to Data.")
         return nil
      }
      
      do {
         let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
         guard let jsonDictionary = jsonObject as? [String: Any],
               let notificationsArray = jsonDictionary["notifications"] as? [String] else {
            print("Error parsing ChatGPT JSON object.")
            return nil
         }
         
         return notificationsArray
      } catch {
         print("Error deserializing JSON data: \(error.localizedDescription)")
         return nil
      }
   }
   
   func getAINotifications(_ n: Int, adjective: String, level: Int = 0) async throws -> [String]? {
      guard level <= 3 else { return nil }
      
      try Task.checkCancellation()
      
      var list: [String] = []
      var answer: String!
      print("Fetching \(n) \(adjective) notifications for habit \(habit.name) from ChatGPT... level: \(level)")
      do {
         let chatGPTAnswer = try await chatGPT.queryChatGPT(prompt: notificationPrompt(n: n, adjective: adjective), maxTokens: 400)
         answer = chatGPTAnswer
      } catch {
         print("Error getting response from ChatGPT: \(error.localizedDescription)")
         return try await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      
      guard let parsedList = parseGPTAnswerIntoArray(answer) else {
         return try await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      list = parsedList
      
      // accept if received 80% or more of requested notifications
      guard list.count >= Int(0.8 * Double(n)) else {
         return try await getAINotifications(n, adjective: adjective, level: level + 1)
      }
      
      list = list.map { $0.trimmingCharacters(in: .whitespaces) }
      
      list.removeAll { $0.isEmpty || $0 == "" }
      
      // Randomize
      list.shuffle()
      
      print("ChatGPT notifications: \(list)")
      return list
   }
}
