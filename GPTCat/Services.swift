//
//  Services.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//
import Foundation


class OpenRouterService {
    private let apiKey: String
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendMessage(messages: [Message], model: String = "openai/gpt-3.5-turbo") async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let messageDict = messages.map { ["role": $0.role, "content": $0.content] }
        let body = OpenRouterRequest(model: model, messages: messageDict)
        request.httpBody = try JSONEncoder().encode(body)

        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        
        return response.choices.first?.message.content ?? "No response"
    }
}

