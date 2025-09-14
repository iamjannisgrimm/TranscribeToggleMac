# TranscribeToggle

A macOS menu bar app for speech-to-text transcription using OpenAI's Whisper API. Record audio with global hotkeys and automatically paste transcribed text wherever your cursor is.

## Features

- **Global Hotkeys**: Press ⌥⌘T to start recording, Enter to stop and transcribe
- **Menu Bar Integration**: Clean menu bar interface with recording status indicator
- **Auto-paste**: Transcribed text is automatically pasted at your cursor location
- **Smart Hotkey Management**: Enter key only works during active recording sessions
- **Bluetooth Audio Support**: Optimized for AirPods and other Bluetooth microphones

## Requirements

- macOS 14.0 or later
- Microphone access permissions
- OpenAI API key

## Setup

1. **Set your OpenAI API key** as an environment variable:
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

2. **Grant Permissions**:
   - Microphone access (prompted on first run)
   - Accessibility access may be required for auto-paste functionality

## Usage

1. Launch TranscribeToggle - it will appear in your menu bar with a microphone icon
2. Press ⌥⌘T anywhere on your system to start recording
3. Press Enter to stop recording and transcribe
4. The transcribed text will automatically be pasted at your cursor location
5. View the last transcription in the menu bar dropdown

## Technical Details

- Built with SwiftUI and AVFoundation
- Uses Carbon framework for global hotkey registration
- Integrates with OpenAI's Whisper API for speech recognition
- Implements smart session tracking to prevent hotkey conflicts

## Privacy

- Audio is only processed for transcription purposes
- No audio data is stored permanently
- All processing happens through OpenAI's API according to their privacy policy