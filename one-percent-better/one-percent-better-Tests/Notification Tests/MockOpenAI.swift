//
//  MockOpenAI.swift
//  one-percent-betterTests
//
//  Created by Jeremy Cook on 6/25/23.
//

import Foundation
@testable import One_Percent_Better

class MockOpenAI: ChatGPTDelegate {
   func queryChatGPT(prompt: String, maxTokens: Int) async throws -> String {
      return "response"
   }
}
