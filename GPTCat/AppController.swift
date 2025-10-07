//
//  AppController.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-02.
//


import SwiftUI
import Combine

class AppController: ObservableObject {
    @Published var apiKey: String = ""
    @Published var chats: [Chat] = []
    @Published var currentChatId: UUID?
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var freeOnly = false
    @Published var selectedModelDescription = ""
    @Published var selectedProvider: String = ""
    @Published var selectedModel: String = "openai/gpt-5-nano"
    @Published var availableModels : [String] = ["openai/gpt-5-nano"]
    @Published var providers : [String] = []

    let defaultModels = [
        "openai/gpt-5-nano",
        "openai/gpt-5",
        "google/gemini-2.5-flash",
        "anthropic/claude-sonnet-4.5",
    ]

    private var apiService: OpenRouter?
    private var storage: ChatStorage?
    private let models = OpenRouterModels()
    
    private var emptyProvider = "All Providers"
    var currentChat: Chat? {
        guard let currentChatId = currentChatId else { return nil }
        return chats.first { $0.id == currentChatId }
    }
    
    var messages: [Message] {
        return currentChat?.messages ?? []
    }

    init() {
        selectedProvider = emptyProvider
        storage = ChatStorage()
        loadApiKey()
        Task { @MainActor in
            do {
                try await self.models.downloadModels()
                loadModels()
                getProviders()
                loadSelectedModel()
            } catch {
                availableModels = defaultModels
            }
        }
        loadChats()
        
        // Create a new chat if none exist
        if chats.isEmpty {
            createNewChat()
        } else {
            // Select the most recent chat
            currentChatId = chats.first?.id
        }
    }

    func saveSelectedModel(){
        UserDefaults.standard.set(selectedModel, forKey: "openrouter_api_model")
    }
    
    func loadSelectedModel(){
        if let saved = UserDefaults.standard.string(forKey: "openrouter_api_model") {
            selectedModel = saved
            getModelDescription()
        }
    }
    
    func setApiKey(_ key: String) {
        apiKey = key
        apiService = OpenRouter(apiKey: key)
        Keychain.save(key: "openrouter_api_key", value: key)
    }
    
    func loadApiKey() {
        if let saved = Keychain.read(key: "openrouter_api_key") {
            apiKey = saved
            apiService = OpenRouter(apiKey: saved)
        }
    }
    
    func getProviders(_ freeOnly: Bool = false){
        providers = [emptyProvider] + models.getProviderList(freeOnly)
    }
    
    func loadModels (freeOnly: Bool = false, provider: String = "" ){
        var prov = provider
        if prov == emptyProvider {
            prov = ""
        }
        
        getProviders(freeOnly)
        availableModels = models.getModelList(freeOnly: freeOnly, provider: prov)
        if !availableModels.contains(selectedModel){
            selectedModel = availableModels.first ?? ""
        }
        getModelDescription()
    }


    func getModelDescription() {
        selectedModelDescription =  models.getModelDescription(selectedModel)
    }
    
    func resetSettings(){
        loadSelectedModel()
        selectedProvider = emptyProvider
    }
    
    func loadChats() {
        chats = storage?.loadAllChats() ?? []
    }
    
    func createNewChat() {
        let newChat = Chat()
        chats.insert(newChat, at: 0) // Insert at beginning for most recent first
        currentChatId = newChat.id
    }
    
    func selectChat(id: UUID) {
        currentChatId = id
    }
    
    func deleteChat(id: UUID) {
        storage?.deleteChat(id: id)
        chats.removeAll { $0.id == id }
        
        // If we deleted the current chat, select another one or create new
        if currentChatId == id {
            if let firstChat = chats.first {
                currentChatId = firstChat.id
            } else {
                createNewChat()
            }
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              apiService != nil,
              var currentChat = currentChat else { return }
        
        let userMessage = Message(role: "user", content: inputText)
        currentChat.addMessage(userMessage)
        inputText = ""
        isLoading = true
        
        if let index = chats.firstIndex(where: { $0.id == currentChat.id }) {
            chats[index] = currentChat
        }
        
        Task {
            do {
                let response = try await apiService?.sendMessage(messages: currentChat.messages, model: selectedModel)
                let assistantMessage = Message(role: "assistant", content: response ?? "")
                currentChat.addMessage(assistantMessage)
                
                // Update the chat in our array
                DispatchQueue.main.async {
                    if let index = self.chats.firstIndex(where: { $0.id == currentChat.id }) {
                        self.chats[index] = currentChat
                    }
                    self.storage?.saveChat(currentChat)
                    self.isLoading = false
                }
            } catch {
                let errorMessage = Message(role: "assistant", content: "Error: \(error.localizedDescription)")
                currentChat.addMessage(errorMessage)
                
                DispatchQueue.main.async {
                    if let index = self.chats.firstIndex(where: { $0.id == currentChat.id }) {
                        self.chats[index] = currentChat
                    }
                    self.storage?.saveChat(currentChat)
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearCurrentChat() {
        guard let currentChatId = currentChatId else { return }
        deleteChat(id: currentChatId)
    }
}
