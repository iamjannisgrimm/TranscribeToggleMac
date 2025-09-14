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
import AVFoundation
import Carbon
import Combine

/// Main app structure that creates a menu bar application
@main
struct TranscribeToggleApp: App {
    @StateObject private var transcriber = MenuBarTranscriber()

    var body: some Scene {
        MenuBarExtra("TranscribeToggle", systemImage: transcriber.isRecording ? "mic.fill" : "mic") {
            VStack(alignment: .leading, spacing: 8) {
                if transcriber.isRecording {
                    Text("🔴 Recording...")
                        .font(.headline)
                    Text("Press Enter to transcribe and paste")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Press ⌥⌘T to start recording")
                        .font(.headline)
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

                Button("Quit TranscribeToggle") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .frame(width: 250)
        }
    }
}

/// Core transcription engine that handles audio recording, hotkey management, and OpenAI API integration
class MenuBarTranscriber: ObservableObject {
    @Published var isRecording = false
    @Published var lastTranscription = ""

    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("transcribe_recording.wav")

    // Carbon hotkey management
    private var startHotKeyRef: EventHotKeyRef?
    private var stopHotKeyRef: EventHotKeyRef?
    private var stopHotKeyHandler: EventHandlerRef?

    // Session state tracking to prevent Enter key interference
    private var hasActiveRecordingSession = false

    private let apiKey: String

    init() {
        // Get API key from environment variable or use placeholder
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "your-openai-api-key-here"

        setupStartHotkey()
        hasActiveRecordingSession = false
        unregisterStopHotkey()
    }

    deinit {
        if let startRef = startHotKeyRef {
            UnregisterEventHotKey(startRef)
        }
        unregisterStopHotkey()
    }

    private func setupStartHotkey() {
        let keyCode: UInt32 = 17 // T key
        let modifiers: UInt32 = UInt32(optionKey | cmdKey)

        var hotKeyId = EventHotKeyID()
        hotKeyId.signature = OSType(0x54434854) // 'TCHT'
        hotKeyId.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        InstallEventHandler(GetEventDispatcherTarget(), { _, event, userData in
            let transcriber = Unmanaged<MenuBarTranscriber>.fromOpaque(userData!).takeUnretainedValue()
            DispatchQueue.main.async {
                transcriber.handleStartHotkey()
            }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), nil)

        RegisterEventHotKey(keyCode, modifiers, hotKeyId, GetEventDispatcherTarget(), 0, &startHotKeyRef)
    }

    private func registerStopHotkey() {
        guard stopHotKeyRef == nil else { return }

        let keyCode: UInt32 = 36 // Enter key
        let modifiers: UInt32 = 0 // No modifiers

        var hotKeyId = EventHotKeyID()
        hotKeyId.signature = OSType(0x454E5452) // 'ENTR'
        hotKeyId.id = 2

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        InstallEventHandler(GetEventDispatcherTarget(), { _, event, userData in
            let transcriber = Unmanaged<MenuBarTranscriber>.fromOpaque(userData!).takeUnretainedValue()
            DispatchQueue.main.async {
                transcriber.handleStopHotkey()
            }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &stopHotKeyHandler)

        RegisterEventHotKey(keyCode, modifiers, hotKeyId, GetEventDispatcherTarget(), 0, &stopHotKeyRef)
    }

    private func unregisterStopHotkey() {
        if let hotKeyRef = stopHotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            stopHotKeyRef = nil
        }

        if let handlerRef = stopHotKeyHandler {
            RemoveEventHandler(handlerRef)
            stopHotKeyHandler = nil
        }
    }

    func handleStartHotkey() {
        if !isRecording {
            hasActiveRecordingSession = true
            unregisterStopHotkey()
            registerStopHotkey()
            startRecording()
        }
    }

    func handleStopHotkey() {
        guard hasActiveRecordingSession else { return }

        if isRecording {
            hasActiveRecordingSession = false
            unregisterStopHotkey()
            stopRecording()
        } else {
            hasActiveRecordingSession = false
            unregisterStopHotkey()
        }
    }

    private func startRecording() {
        isRecording = true

        audioEngine.stop()
        audioEngine.reset()

        let inputNode = audioEngine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        do {
            audioFile = try AVAudioFile(forWriting: tempURL, settings: format.settings)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                guard let self = self, let file = self.audioFile else { return }
                do {
                    try file.write(from: buffer)
                } catch {
                    // Silent audio write error handling
                }
            }

            try audioEngine.start()
        } catch {
            isRecording = false
            hasActiveRecordingSession = false
            unregisterStopHotkey()
        }
    }

    private func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        audioFile = nil
        isRecording = false

        transcribeAndPaste()
    }

    private func transcribeAndPaste() {
        guard FileManager.default.fileExists(atPath: tempURL.path),
              let audioData = try? Data(contentsOf: tempURL) else {
            return
        }

        let boundary = UUID().uuidString
        var data = Data()

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        data.append("whisper-1\r\n".data(using: .utf8)!)

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        data.append(audioData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { responseData, response, error in
            DispatchQueue.main.async {
                guard let responseData = responseData,
                      error == nil,
                      let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                      let text = json["text"] as? String else {
                    return
                }

                self.lastTranscription = text
                self.pasteText(text)
            }
        }.resume()
    }

    private func pasteText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let source = CGEventSource(stateID: .hidSystemState)

            let cmdVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            let cmdVUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)

            cmdVDown?.flags = .maskCommand
            cmdVUp?.flags = .maskCommand

            cmdVDown?.post(tap: .cghidEventTap)
            cmdVUp?.post(tap: .cghidEventTap)
        }
    }
}