//
//  SettingsView.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-06.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.dismiss) var dismiss
    @State private var tempApiKey = ""
    @State private var freeOnly = false
    
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
                    Text("Filter models")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Provider")
                            .font(.headline)
                   
                        HStack(alignment: .center, spacing: 15){
                            Picker("Select Provider", selection: $appController.selectedProvider) {
                                ForEach(appController.providers, id: \.self) { provider in
                                    Text(provider).tag(provider)
                                }
                            }
                            .onChange(of: appController.selectedProvider) {
                                appController.loadModels(freeOnly: freeOnly, provider: appController.selectedProvider)
                            }
                            .pickerStyle(.menu)
                            
                            Toggle("Free only", isOn: $freeOnly)
                                .toggleStyle(.checkbox)
                                .onChange(of: freeOnly) {
                                    appController.loadModels(freeOnly: freeOnly, provider: appController.selectedProvider)
                                }
                                
                        }
                    }
                    
                    .padding(.vertical)
                
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
                .onChange(of: appController.selectedModel) {
                    appController.getModelDescription()
                }
                .pickerStyle(.menu)
            }
            
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(appController.selectedModelDescription)
                    .font(.headline)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
            }

                Spacer()

                HStack {
                    Button("Cancel") {
                        appController.resetSettings()
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Save") {
                        appController.setApiKey(tempApiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                        appController.saveSelectedModel()
                        dismiss()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(appController.selectedModelDescription.isEmpty)
                }
            .padding()
        }
        .frame(width: 500, height: 600)
    }
}
