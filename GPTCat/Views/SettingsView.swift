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
