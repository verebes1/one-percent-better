//
//  OpenAI.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import OpenAISwift

enum OpenAIError: Error {
   case emptyMessageResponse
}

class OpenAI {
   static var shared = OpenAI()
   
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
   
   func chatModel(prompt: String) async throws -> String {
      return try await withCheckedThrowingContinuation { continuation in
         openAI.sendChat(with: [ChatMessage(role: .user, content: prompt)], model: .chat(.chatgpt), maxTokens: 400) { result in
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
