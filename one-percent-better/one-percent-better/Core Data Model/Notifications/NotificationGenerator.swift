//
//  NotificationGenerator.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/28/23.
//

import Foundation

protocol NotificationGeneratorDelegate {
    func generateNotifications(habitName: String) async throws -> [String]
}

class NotificationGenerator: NotificationGeneratorDelegate {
    
    var habitName: String!
    var chatGPT: ChatGPTDelegate = OpenAIManager()
    
    func notificationPrompt(n: Int, adjective: String) -> String {
        return """
             Task: Generate \(n) different examples of a \(adjective) notification to encourage someone to do their habit named "\(habitName.lowercased())".
             Requirements: For each notification, use between 20 and 100 characters. Return them as a JSON array named "notifications".
             """
    }
    
    func generateNotifications(habitName: String) async throws -> [String] {
        self.habitName = habitName
        // Need a sleep time between GPT-4 requests: Rate limit reached for gpt-4 in organization on tokens per min. Limit: 10000 / min. Please try again in 6ms. Visit https://platform.openai.com/account/rate-limits to learn more.
        let sleepTime = 10
        var notifs: [String] = []
        async let creative = try await getAINotifications(5, adjective: "creative")
        try await Task.sleep(for: .milliseconds(sleepTime))
        async let motivating = try await getAINotifications(5, adjective: "motivating")
        try await Task.sleep(for: .milliseconds(sleepTime))
        async let sassy = try await getAINotifications(5, adjective: "sassy")
        try await Task.sleep(for: .milliseconds(sleepTime))
        async let funny = try await getAINotifications(8, adjective: "funny")
        try await Task.sleep(for: .milliseconds(sleepTime))
        async let punny = try await getAINotifications(5, adjective: "punny")
        try await Task.sleep(for: .milliseconds(sleepTime))
        async let rhyming = try await getAINotifications(5, adjective: "rhyming")
        let allResults = try await [creative, motivating, sassy, funny, punny, rhyming]
        notifs = allResults
            .flatMap { $0 }
            .shuffled()
        
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
        return notifs.map { $0.replacingOccurrences(of: "XX", with: habitName.lowercased()) }
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
    
    func getAINotifications(_ n: Int, adjective: String, retryAttempt: Int = 0) async throws -> [String] {
        guard retryAttempt <= 3 else { return [] }
        
        try Task.checkCancellation()
        
        var list: [String] = []
        var answer: String!
        print("Fetching \(n) \(adjective) notifications for habit \(habitName!) from ChatGPT... level: \(retryAttempt)")
        do {
            let chatGPTAnswer = try await chatGPT.queryChatGPT(prompt: notificationPrompt(n: n, adjective: adjective), maxTokens: 400)
            answer = chatGPTAnswer
        } catch {
            print("Error getting response from ChatGPT: \(error.localizedDescription)")
            return try await getAINotifications(n, adjective: adjective, retryAttempt: retryAttempt + 1)
        }
        
        guard let parsedList = parseGPTAnswerIntoArray(answer) else {
            return try await getAINotifications(n, adjective: adjective, retryAttempt: retryAttempt + 1)
        }
        list = parsedList
        
        // accept if received 80% or more of requested notifications
        guard list.count >= Int(0.8 * Double(n)) else {
            return try await getAINotifications(n, adjective: adjective, retryAttempt: retryAttempt + 1)
        }
        
        list = list.map { $0.trimmingCharacters(in: .whitespaces) }
        
        list.removeAll { $0.isEmpty || $0 == "" }
        
        // Randomize
        list.shuffle()
        
        print("ChatGPT notifications: \(list)")
        return list
    }
}
