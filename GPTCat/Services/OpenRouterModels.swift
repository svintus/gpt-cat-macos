//
//  Untitled.swift
//  GPTCat
//
//  Created by Polina Sergeyenko on 10/6/25.
//

//
//  Services.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//
import Foundation


class OpenRouterModels {
    private let baseURL = "https://openrouter.ai/api/v1/models"
    
    func getModelList() async throws -> [String] {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try? JSONDecoder().decode(ModelListResponse.self, from: data)
        if let result = response?.data {
            var list: [String] = []
            for model in result {
                list.append(model.id)
            }
            return list
        }
        
        let error = try? JSONDecoder().decode(OpenRouterError.self, from: data)
        
        
        return  ["Error: " + (error?.error.message ?? "No Responce")]
        
    }
    
    
}

