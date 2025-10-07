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
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var selectedModel: String = "openai/gpt-5-nano"
    @Published var availableModels : [String] = ["openai/gpt-5-nano"]
    @Published var providers : [String] = []

    let defaultModels = [
        "openai/gpt-5-nano",
        "openai/gpt-5",
        "google/gemini-2.5-flash",
        "anthropic/claude-sonnet-4.5",
    ]
    
    private var service: OpenRouter?
    private var storage: ChatStorage?
    private let models = OpenRouterModels()

    init() {
        storage = ChatStorage()
        loadApiKey()
        messages = storage?.loadConversation() ?? []
        Task { @MainActor in
            do {
                try await self.models.downloadModels()
                loadModels()
                providers = models.getProviderList()
            } catch {
                availableModels = defaultModels
            }
        }
    }

    func setApiKey(_ key: String) {
        apiKey = key
        service = OpenRouter(apiKey: key)
        Keychain.save(key: "openrouter_api_key", value: key)
    }
    
    func loadApiKey() {
        if let saved = Keychain.read(key: "openrouter_api_key") {
            apiKey = saved
            service = OpenRouter(apiKey: saved)
        }
    }
    
    func loadModels (freeOnly: Bool = false, provider: String = "" ){
        availableModels = models.getModelList(freeOnly: freeOnly, provider: provider)
        //not sure this is good idea
        if availableModels.isEmpty {
            availableModels = defaultModels
        }
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              service != nil else { return }
        
        let userMessage = Message(role: "user", content: inputText)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        
        Task { @MainActor in
            do {
                let response = try await service?.sendMessage(messages: messages, model: selectedModel)
                let assistantMessage = Message(role: "assistant", content: response ?? "")
                messages.append(assistantMessage)
            } catch {
                let errorMessage = Message(role: "assistant", content: "Error: \(error.localizedDescription)")
                messages.append(errorMessage)
            }
            storage?.saveConversation(messages: messages)
            isLoading = false
        }
    }
    
    func clearChat() {
        storage?.deleteConversation()
        messages.removeAll()
    }
}
