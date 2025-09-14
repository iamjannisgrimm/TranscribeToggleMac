//
//  ContentView.swift
//  TranscribeToggle
//
//  A macOS menu bar app for speech-to-text transcription using OpenAI's Whisper API.
//  Press ⌥⌘T to start recording, Enter to stop and paste transcribed text.
//
//  Created by Jannis Grimm on 9/14/25.
//

import SwiftUI

/// Main app structure that creates a menu bar application
@main
struct TranscribeToggleApp: App {
    @StateObject private var transcriber = MenuBarTranscriber()

    var body: some Scene {
        MenuBarExtra("TranscribeToggle", systemImage: transcriber.isRecording ? "mic.fill" : "mic") {
            MainView(transcriber: transcriber)
                .padding()
                .frame(width: 280)
        }

        Window("TranscribeToggle Settings", id: "settings") {
            SettingsWindowView(transcriber: transcriber)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}