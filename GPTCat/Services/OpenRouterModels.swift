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
    private var models: [ModelData] = []
    
    func downloadModels() async throws  {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let response = try? JSONDecoder().decode(ModelListResponse.self, from: data)
        if let result = response?.data {
            models = result
        }else {
            models = []
        }
        
    }
    
    func getProviderList() -> [String]{
        return Array(Set( models.map { String($0.id.split(separator: "/").first ?? "") })).sorted()
    }
    
    func getModelList(freeOnly: Bool = false, provider: String = "") -> [String]{
        if models.isEmpty {
            return []
        }
        
        var filtered = models
        if freeOnly{
            filtered = getFreeOnly(filtered)
        }
        
        if !provider.isEmpty {
            filtered = getByProvider(filtered,provider: provider)
        }
        
        return filtered.map { $0.id }
    }
    
    private func getFreeOnly(_ data: [ModelData]) -> [ModelData]{
        return data.filter({$0.id.hasSuffix(":free")})
    }
    
    private func getByProvider(_ data: [ModelData], provider provider: String) -> [ModelData]{
        let filter = provider + "/"
        return data.filter({$0.id.hasPrefix(filter)})
    }
    
    
    
    
    
}

