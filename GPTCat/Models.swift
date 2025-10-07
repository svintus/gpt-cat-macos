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


//Model structures
struct ModelListResponse: Codable {
    let data: [ModelData]
}

struct ModelData: Codable, Identifiable {
    let id: String
    let name: String?
    let created: Int?
    let description: String?
    let architecture: Architecture?
    let topProvider: TopProvider?
    let pricing: Pricing?
    let canonicalSlug: String?
    let contextLength: Int?
    let huggingFaceId: String?
    let perRequestLimits: [String: String]?
    let supportedParameters: [String]?
    let defaultParameters: DefaultParameters?
    
    enum CodingKeys: String, CodingKey {
        case id, name, created, description, architecture, pricing
        case topProvider = "top_provider"
        case canonicalSlug = "canonical_slug"
        case contextLength = "context_length"
        case huggingFaceId = "hugging_face_id"
        case perRequestLimits = "per_request_limits"
        case supportedParameters = "supported_parameters"
        case defaultParameters = "default_parameters"
    }
}

struct Architecture: Codable {
    let inputModalities: [String]
    let outputModalities: [String]
    let tokenizer: String
    let instructType: String?

    enum CodingKeys: String, CodingKey {
        case inputModalities = "input_modalities"
        case outputModalities = "output_modalities"
        case tokenizer
        case instructType = "instruct_type"
    }
}

struct TopProvider: Codable {
    let isModerated: Bool
    let contextLength: Double?
    let maxCompletionTokens: Double?

    enum CodingKeys: String, CodingKey {
        case isModerated = "is_moderated"
        case contextLength = "context_length"
        case maxCompletionTokens = "max_completion_tokens"
    }
}

struct Pricing: Codable {
    let prompt: String
    let completion: String
    let image: String?
    let request: String?
    let webSearch: String?
    let internalReasoning: String?
    let inputCacheRead: String?
    let inputCacheWrite: String?

    enum CodingKeys: String, CodingKey {
        case prompt
        case completion
        case image
        case request
        case webSearch = "web_search"
        case internalReasoning = "internal_reasoning"
        case inputCacheRead = "input_cache_read"
        case inputCacheWrite = "input_cache_write"
    }
}

struct DefaultParameters: Codable {
    let temperature: Double?
    let topP: Double?
    let frequencyPenalty: Double?

    enum CodingKeys: String, CodingKey {
        case temperature
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
    }
}
