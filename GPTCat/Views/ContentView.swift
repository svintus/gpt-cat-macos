//
//  ContentView.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-06.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var appController: AppController
    @Environment(\.openSettings) private var openSettings
    @State private var showingSettings = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar with chat list
            ChatSidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            // Main chat view
            ChatDetailView()
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            appController.loadApiKey()
            if appController.apiKey.isEmpty {
                openSettings()
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: { appController.clearCurrentChat() }) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete Chat")
            }
        }
    }
}
