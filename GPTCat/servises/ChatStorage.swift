//
//  Storage.swift
//  GPTCat
//
//  Created by Polina Sergeyenko on 10/2/25.
//

import Foundation

class ChatStorage {
    private let directoryURL: URL
    
    init(directoryName: String = "conversations") {
        let fileManager = FileManager.default
        
        // Use user's Documents directory
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.directoryURL = documentsURL.appendingPathComponent(directoryName)
        
        // Create directory if not exists
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
    
    /// Save Codable object as JSON
    private func save<T: Codable>(_ object: T, to filename: String) throws {
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(object)
        try data.write(to: fileURL)
    }
    
    /// Load Codable object from JSON
    private func load<T: Codable>(_ type: T.Type, from filename: String) throws -> T {
        let fileURL = directoryURL.appendingPathComponent(filename)
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    /// List all files in storage directory
    private func listFiles() -> [String] {
        let fileManager = FileManager.default
        let files = (try? fileManager.contentsOfDirectory(atPath: directoryURL.path)) ?? []
        return files
    }
    
    private func delete(filename: String) throws {
        let fileURL = directoryURL.appendingPathComponent(filename)
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func saveConversation(messages: [Message], model: String = "openai/gpt-3.5-turbo"){
        
        let filename = messages.first?.id.uuidString  ?? "No_ID"
        
        let messageDict = messages.map { ["role": $0.role, "content": $0.content] }
        let data = OpenRouterRequest(model: model, messages: messageDict)
        try? save(data, to: filename)
        
    }
    
    func loadConversations() -> [[Message]]{
        let files = listFiles()
        var data:[[Message]] = []
        for file in files {
            let conversation = loadConversation(filename: file)
            if conversation.count > 0  {
                data.append(conversation)
            }
        }
        return data
    }
    
    func loadConversation(filename: String) -> [Message] {
        let data = try? load(OpenRouterRequest.self, from: filename)
        if let messages = data?.messages {
            let converted = messages.map(makeMessage)
            return converted.compactMap{$0}
        }
        return []
    }
    
    func loadConversation() -> [Message]{
        let files = listFiles()
        if let filename = files.first {
            return loadConversation(filename: filename)
        }
        return []
    }
    
    func deleteConversation(filename: String = ""){
        if filename != "" {
            try? delete(filename: filename)
        }else{
            let files = listFiles()
            if let filename = files.first {
                try? delete(filename: filename)
            }
        }
    }
    
    private func makeMessage( _ data: Dictionary<String,String>) -> Message?{
        var role = ""
        var content = ""
        for line in data {
            if line.key == "role" {
                role = line.value
            }else{
                content = line.value
            }
        }
        if role != "" && content != ""{
            return Message(role: role, content: content)
        }
        return nil
    }
}
