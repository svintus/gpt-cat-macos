//
//  Models.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//

import Foundation


struct Message: Identifiable, Codable {
    let id = UUID()
    let role: String
    let content: String
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

