//
//  OpenAI.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 3/3/23.
//

import Foundation
import OpenAI

protocol ChatGPTDelegate {
    func queryChatGPT(prompt: String, maxTokens: Int) async throws -> String
}

enum OpenAIError: Error {
    case emptyMessageResponse
}

class OpenAIManager: ChatGPTDelegate {
    static var shared = OpenAIManager()
    
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
    
    let openAI: OpenAI
    
    init() {
        openAI = OpenAI(apiToken: openAIKey)
    }
    
    /// Query ChatGPT with a prompt and maxTokens
    func queryChatGPT(prompt: String, maxTokens: Int = 400) async throws -> String {
        let query = ChatQuery(model: .gpt4, messages: [.init(role: .assistant, content: prompt) ], maxTokens: maxTokens)
        let result = try await openAI.chats(query: query)
        if let answer = result.choices.first?.message.content {
            return answer
        } else {
            throw OpenAIError.emptyMessageResponse
        }
    }
}
