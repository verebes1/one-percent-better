//
//  OpenAI.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import OpenAISwift

protocol ChatGPTDelegate {
   func queryChatGPT(prompt: String, maxTokens: Int) async throws -> String
}

enum OpenAIError: Error {
   case emptyMessageResponse
}

class OpenAI: ChatGPTDelegate {
   static var shared = OpenAI()
   
   /// The OpenAI API key is stored in this plist which is not included in the repository
   var openAIKey: String = {
      var keys: NSDictionary?
      if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
         keys = NSDictionary(contentsOfFile: path)
      }
      
      if let dict = keys,
         let apiKey = dict["OPEN_AI_KEY"] as? String {
         return apiKey
      } else {
         return ""
      }
   }()
   
   let openAI: OpenAISwift
   
   init() {
      openAI = OpenAISwift(authToken: openAIKey)
   }
   
   /// Query ChatGPT with a prompt and maxTokens
   func queryChatGPT(prompt: String, maxTokens: Int = 400) async throws -> String {
      return try await withCheckedThrowingContinuation { continuation in
         openAI.sendChat(with: [ChatMessage(role: .user, content: prompt)], model: .chat(.chatgpt), maxTokens: maxTokens) { result in
            switch result {
            case .success(let success):
               if let ans = success.choices?.first?.message.content {
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
}
