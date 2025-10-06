//
//  Models.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: UUID
    var messages: [Message]
    var summary: String
    let createdAt: Date
    
    init(id: UUID = UUID(), messages: [Message] = [], summary: String = "New Chat", createdAt: Date = Date()) {
        self.id = id
        self.messages = messages
        self.summary = summary
        self.createdAt = createdAt
    }
    
    mutating func addMessage(_ message: Message) {
        messages.append(message)
        
        // Generate a simple summary from the first user message if summary is still default
        if summary == "New Chat" && message.role == "user" {
            let words = message.content.components(separatedBy: .whitespacesAndNewlines)
            let firstWords = Array(words.prefix(5)).joined(separator: " ")
            summary = firstWords.isEmpty ? "New Chat" : firstWords
        }
    }
}

struct Message: Identifiable, Codable {
    let id: UUID
    let role: String
    let content: String
    
    init(id: UUID = UUID(), role: String, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}

struct OpenRouterRequest: Codable {
    let model: String
    let messages: [[String: String]]
}

struct OpenRouterResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: MessageContent
    }
    
    struct MessageContent: Codable {
        let content: String
    }
}


struct OpenRouterError: Codable {
    let error: ErrorData
    
    struct ErrorData: Codable {
        let message: String
        let code: Int
    }

}


