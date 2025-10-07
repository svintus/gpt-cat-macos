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
    let createdAt: Date
    
    init(id: UUID = UUID(), messages: [Message] = [], createdAt: Date = Date()) {
        self.id = id
        self.messages = messages
        self.createdAt = createdAt
    }

    var summary: String {
        guard let message = messages.filter({$0.role == "user"}).first else {
            return "New Chat"
        }
        return message.content
    }

    
    mutating func addMessage(_ message: Message) {
        messages.append(message)
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


