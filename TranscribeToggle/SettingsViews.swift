//
//  SettingsViews.swift
//  TranscribeToggle
//
//  SwiftUI views for settings and configuration UI
//
//  Created by Jannis Grimm on 9/14/25.
//

import SwiftUI

/// Main menu bar view showing recording status and controls
struct MainView: View {
    @ObservedObject var transcriber: MenuBarTranscriber
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if transcriber.isRecording {
                Text("🔴 Recording...")
                    .font(.headline)
                Text("Press Enter to transcribe and paste")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if transcriber.isAPIKeyConfigured {
                Text("Press ⌥⌘T to start recording")
                    .font(.headline)
            } else {
                Text("⚠️ API key required")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("Click Settings to configure")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !transcriber.lastTranscription.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last transcription:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(transcriber.lastTranscription)
                        .font(.caption)
                        .lineLimit(3)
                }
            }

            Divider()

            HStack {
                Button("Settings") {
                    openWindow(id: "settings")
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Settings window view for configuring API key
struct SettingsWindowView: View {
    @ObservedObject var transcriber: MenuBarTranscriber
    @State private var tempAPIKey = ""
    @State private var showSaved = false
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("TranscribeToggle Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Divider()

            // API Key Section
            VStack(alignment: .leading, spacing: 12) {
                Text("OpenAI API Key")
                    .font(.headline)

                Text("Enter your OpenAI API key to enable speech transcription:")
                    .font(.body)
                    .foregroundColor(.secondary)

                SecureField("sk-proj-...", text: $tempAPIKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                HStack {
                    Button("Save") {
                        transcriber.saveAPIKey(tempAPIKey)
                        showSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSaved = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(tempAPIKey.isEmpty)

                    if showSaved {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Saved")
                                .foregroundColor(.green)
                        }
                        .font(.body)
                    }

                    Spacer()

                    Button("Close") {
                        dismissWindow(id: "settings")
                    }
                }

                // Help text
                VStack(alignment: .leading, spacing: 4) {
                    Text("To get your API key:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("1. Visit platform.openai.com/api-keys")
                        .font(.caption)
                    Text("2. Create a new API key")
                        .font(.caption)
                    Text("3. Copy and paste it above")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 450, height: 280)
        .onAppear {
            tempAPIKey = transcriber.apiKey
        }
    }
}