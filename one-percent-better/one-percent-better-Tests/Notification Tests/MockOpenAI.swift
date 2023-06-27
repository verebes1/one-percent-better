//
//  MockOpenAI.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/25/23.
//

import Foundation
@testable import ___Better

class MockOpenAI: OpenAIRequest {
   func query(prompt: String) async throws -> String {
      try await Task.sleep(for: .milliseconds(Int.random(in: 1 ... 30 )))
      let exampleJsonNotifs = """
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
      return exampleJsonNotifs
   }
}
