//
//  ContentView.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//

import SwiftUI
import Combine


struct ChatSidebarView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.openSettings) private var openSettings

    @State private var selectedChat: UUID?

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("GPT Cat  🐈")
                    .font(.headline)
                    .padding()

                Spacer()
                Button(action: {
                    appController.createNewChat()
                    selectedChat = appController.currentChat!.id
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Chat")
                .padding()

            }
            
            Divider()
            
            // Chat list
            List(appController.chats, selection: $selectedChat) { chat in
                ChatRowView(chat: chat)
            }
            .listStyle(.sidebar)
            .onChange(of: selectedChat) {
                if let selectedChat = selectedChat {
                    appController.selectChat(id: selectedChat)
                }
            }

            Button(action: { openSettings() }) {
                // Image(systemName: "gear")
                Label("Settings", systemImage: "gear")
            }
            .accessibilityLabel("Settings")
            .padding()
        }
        .onAppear {
            selectedChat = appController.currentChat?.id
        }
    }
}

struct ChatRowView: View {
    let chat: Chat

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(chat.summary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 2)
    }
}




#Preview {
    ContentView()
}
