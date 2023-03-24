//
//  OpenAI.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import OpenAI

import OpenAISwift

enum OpenAIError: Error {
   case emptyMessageResponse
}

class OpenAI {
   static var shared = OpenAI()
   
   let client = Client(apiKey: "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")
   
   let openAI = OpenAISwift(authToken: "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")
   
   func completionModel(prompt: String) async throws -> String? {
      return try await withCheckedThrowingContinuation { continuation in
         client.completions(engine: .other("text-davinci-003"),
                            prompt: prompt,
                            numberOfTokens: ...400,
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
   
   // Other models
   
   func chatModel(prompt: String) async throws -> String {
      return try await withCheckedThrowingContinuation { continuation in
         openAI.sendChat(with: [ChatMessage(role: .user, content: prompt)], model: .chat(.chatgpt), maxTokens: 400) { result in
            switch result {
            case .success(let success):
               if let ans = success.choices.first?.message.content {
                  continuation.resume(returning: ans)
               } else {
                  continuation.resume(throwing: OpenAIError.emptyMessageResponse)
               }
            case .failure(let failure):
               continuation.resume(throwing: failure)
            }
         }
      }
   }
   
   
   func engines() async throws -> String? {
      return try await withCheckedThrowingContinuation { continuation in
         client.engines { result in
            print(result)
            switch result {
            case .success(let success):
               continuation.resume(returning: success.debugDescription)
            case .failure(let failure):
               continuation.resume(throwing: failure)
            }
         }
      }
   }
}
