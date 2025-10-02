//
//  ContentView.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//

import SwiftUI
import Combine


struct ContentView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.openSettings) private var openSettings
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(appController.messages) { message in
                            MessageBubble(message: message).id(message.id)
                        }

                        if appController.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 12)
                        }
                    }
                    .padding()
                }
                .onChange(of: appController.messages.count) {
                    if let lastMessage = appController.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input area
            HStack(spacing: 12) {
                TextField("Type your message...", text: $appController.inputText)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onSubmit {
                        appController.sendMessage()
                    }
                .overlay(alignment: .trailing) {
                    Button(action: {
                            // TODO do an action here
                            print("Mic button pressed")
                            }) {
                        Image(systemName: "mic")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                        .padding(.trailing, 8)
                }

                Button(action: { appController.sendMessage() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(appController.inputText.isEmpty ? .gray : .blue)
                }
                .buttonStyle(.plain)
                    .disabled(appController.inputText.isEmpty || appController.isLoading)
            }
            .padding()
        }
        .navigationTitle("GPT Cat  🐈")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: { openSettings() }) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: { appController.clearChat() }) {
                        Image(systemName: "trash")
                    }
                }
            }
        .frame(minWidth: 600, minHeight: 400)
            .onAppear {
                appController.loadApiKey()
            }
    }
    
    struct MessageBubble: View {
        let message: Message
        
        var body: some View {
            HStack {
                if message.role == "user" {
                    Spacer()
                }
                
                VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                    Text(message.role.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(message.content)
                        .padding(12)
                        .background(message.role == "user" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(message.role == "user" ? .white : .primary)
                        .cornerRadius(12)
                }
                .frame(maxWidth: 500, alignment: message.role == "user" ? .trailing : .leading)
                
                if message.role == "assistant" {
                    Spacer()
                }
            }
        }
    }
    
}

struct SettingsView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.dismiss) var dismiss
    @State private var tempApiKey = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .padding(.top)

                VStack(alignment: .leading, spacing: 8) {
                    Text("OpenRouter API Key")
                        .font(.headline)

                        SecureField("Enter your API key", text: $tempApiKey)
                        .textFieldStyle(.roundedBorder)
                        .onAppear {
                            tempApiKey = appController.apiKey
                        }

                    Text("Get your API key from openrouter.ai")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Model")
                        .font(.headline)

                        Picker("Select Model", selection: $appController.selectedModel) {
                            ForEach(appController.availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                    .pickerStyle(.menu)
                }
            .padding(.horizontal)

                Spacer()

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)

                        Button("Save") {
                            appController.setApiKey(tempApiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                                dismiss()
                        }
                    .keyboardShortcut(.defaultAction)
                }
            .padding()
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    ContentView()
}
