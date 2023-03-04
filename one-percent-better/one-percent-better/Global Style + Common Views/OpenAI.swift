//
//  OpenAI.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import OpenAI

class OpenAI {
   static var shared = OpenAI()
   
   let client = Client(apiKey: "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")
   
   func completion(prompt: String) async throws -> String? {
      return try await withCheckedThrowingContinuation { continuation in
         client.completions(engine: .other("text-davinci-003"),
                            prompt: prompt,
                            numberOfTokens: ...50,
                            numberOfCompletions: 1) { result in
            switch result {
            case .success(let completions):
               let ans = completions.first?.choices.first?.text
               continuation.resume(returning: ans)
            case .failure(let failure):
               continuation.resume(throwing: failure)
            }
         }
      }
   }
}
