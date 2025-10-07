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
        let fileURL = directoryURL.appendingPathComponent(filename)
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
    
    func saveChat(_ chat: Chat) {
        let filename = chat.id.uuidString + ".json"
        try? save(chat, to: filename)
    }
    
    func loadChat(id: UUID) -> Chat? {
        let filename = id.uuidString + ".json"
        return try? load(Chat.self, from: filename)
    }
    
    func loadAllChats() -> [Chat] {
        let files = listFiles()
        var chats: [Chat] = []
        
        for file in files {
            if let chat = try? load(Chat.self, from: file) {
                chats.append(chat)
            }
        }
        
        // Sort by updatedAt in reverse chronological order (most recent first)
        return chats.sorted { $0.createdAt > $1.createdAt }
    }
    
    func deleteChat(id: UUID) {
        let filename = id.uuidString + ".json"
        try? delete(filename: filename)
    }
}
