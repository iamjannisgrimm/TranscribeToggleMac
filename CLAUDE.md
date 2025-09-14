# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TranscribeToggle is a macOS menu bar application that provides speech-to-text transcription using OpenAI's Whisper API. The app captures audio via a global hotkey (⌥⌘T), transcribes it, and automatically pastes the result into the frontmost application.

## Architecture

All code is contained in a single file structure:
- `TranscribeToggle/ContentView.swift` - Contains the entire application implementation
- Uses a monolithic approach with multiple classes and structs defined in one file

### Key Components

1. **TranscribeToggleApp**: Main SwiftUI App entry point
   - Manages MenuBarExtra UI
   - Coordinates between managers
   - Handles global hotkey registration

2. **Manager Classes** (ObservableObjects):
   - `HotkeyManager`: Registers global ⌥⌘T hotkey using Carbon APIs
   - `TranscriptionManager`: Handles audio recording, processing, and OpenAI API calls
   - `PasteManager`: Manages clipboard operations and system notifications
   - `KeychainHelper`: Secures API key storage in macOS Keychain

3. **PreferencesView**: Settings window for API key and model selection

## Build and Run

This is an Xcode project. Use standard Xcode commands:
- **Build**: `⌘B` in Xcode or `xcodebuild`
- **Run**: `⌘R` in Xcode or `xcodebuild -scheme TranscribeToggle -configuration Debug build`
- **Archive**: Product → Archive in Xcode

## Key Dependencies

- **SwiftUI**: UI framework
- **AVFoundation**: Audio recording and processing
- **Carbon**: Global hotkey registration
- **Security**: Keychain API access
- **AppKit**: Menu bar integration and pasteboard operations

## Configuration Requirements

- OpenAI API key must be set in Preferences
- Microphone permission required (NSMicrophoneUsageDescription in Info.plist)
- App runs with hardened runtime and sandbox enabled

## Audio Processing Flow

1. Records audio at 16kHz mono using AVAudioEngine
2. Converts and writes to temporary WAV file
3. Uploads to OpenAI transcription endpoint
4. Automatically pastes transcribed text via simulated ⌘V

## Important Notes

- All code is in ContentView.swift despite the filename
- Uses OpenAI's `gpt-4o-mini-transcribe` or `gpt-4o-transcribe` models
- API key stored securely in macOS Keychain
- Requires macOS deployment target 26.0+