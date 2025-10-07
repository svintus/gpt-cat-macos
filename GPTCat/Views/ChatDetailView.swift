//
//  ChatDetailView.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-06.
//
import SwiftUI


struct ChatDetailView: View {
    @EnvironmentObject var appController: AppController
    
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

                Button(action: { appController.sendMessage() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(appController.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                .buttonStyle(.plain)
                    .disabled(appController.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appController.isLoading)
                .accessibilityLabel("Submit")
            }
            .padding()
        }
        .navigationTitle(appController.currentChat?.summary ?? "GPT Cat  🐈")
    }
}
