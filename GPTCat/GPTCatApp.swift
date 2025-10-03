//
//  GPTCatApp.swift
//  GPTCat
//
//  Created by Ivan Sergeyenko on 2025-10-01.
//

import SwiftUI
import Combine




@main
struct GPTCatApp: App {
    @StateObject private var appController = AppController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appController)
        }

        Settings {
            SettingsView()
                .environmentObject(appController)
        }
    }
}
