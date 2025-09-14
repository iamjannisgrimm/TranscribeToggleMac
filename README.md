# 🎙️ TranscribeToggle

> **Transform your voice into text instantly, anywhere on macOS**

A beautifully designed menu bar app that brings OpenAI's powerful Whisper AI directly to your fingertips. Record audio with global hotkeys and watch your words appear wherever you're typing - perfect for writing emails, taking notes, or filling forms at lightning speed.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue?style=flat-square&logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange?style=flat-square&logo=swift)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## ✨ Why You'll Love TranscribeToggle

**🚀 Instant Transcription** - Press ⌥⌘T anywhere, speak naturally, hit Enter. Your words appear exactly where you need them.

**🎯 Smart & Unobtrusive** - Lives quietly in your menu bar until you need it. No windows to manage, no apps to switch between.

**🔒 Secure by Design** - API keys stored safely in macOS Keychain. Audio processed only for transcription, never stored.

**🎧 Works with Everything** - Optimized for AirPods, built-in mics, USB headsets, and professional audio equipment.

**⚡ Lightning Fast** - Powered by OpenAI's industry-leading Whisper AI for accurate transcription in seconds.

## 🎬 How It Works

1. **🎙️ Press ⌥⌘T** - Start recording instantly from anywhere
2. **🗣️ Speak naturally** - The app captures your voice in high quality
3. **⌨️ Press Enter** - Stop recording and send to OpenAI's Whisper AI
4. **✨ Watch the magic** - Your transcribed text appears exactly where your cursor is

Perfect for:
- 📧 Writing emails and messages
- 📝 Taking meeting notes
- 📋 Filling out forms
- 💬 Social media posts
- 📚 Content creation
- 🎯 Any text input task

## 🚀 Get Started in 60 Seconds

### Prerequisites
- macOS 14.0 or later
- OpenAI API key ([get one here](https://platform.openai.com/api-keys))

### Installation & Setup

1. **Download & Launch** - Open TranscribeToggle.app (it appears in your menu bar)

2. **Configure API Key** - Click the microphone icon → Settings → paste your OpenAI API key → Save

3. **Grant Permissions** - Allow microphone access when prompted

4. **Start Transcribing!** - Press ⌥⌘T anywhere to begin

### First Time Setup
![Settings Window](https://via.placeholder.com/450x280/f0f0f0/666666?text=Clean+Settings+Interface)

The app will guide you through a one-time setup with clear instructions for getting your API key.

## 🎯 Features That Set Us Apart

### 🔥 Global Hotkey Magic
- **⌥⌘T** to start recording from any app
- **Enter** to stop and transcribe (only works during recording)
- Smart session tracking prevents accidental triggers

### 🎨 Beautiful Interface
- Minimalist menu bar design
- Clean settings window
- Real-time recording status
- Last transcription preview

### 🔐 Enterprise-Grade Security
- API keys encrypted in macOS Keychain
- No audio data stored locally
- Secure HTTPS communication with OpenAI

### 🎵 Professional Audio Support
- Auto-optimized for different microphone types
- Works perfectly with AirPods Pro/Max
- Support for professional USB/XLR setups
- Intelligent audio device switching

## 🏗️ Architecture

TranscribeToggle is built with modern Swift and SwiftUI:

```
📁 Project Structure
├── ContentView.swift          # Main app & menu bar setup
├── MenuBarTranscriber.swift   # Core transcription engine
├── SettingsViews.swift        # Beautiful SwiftUI interfaces
├── KeychainManager.swift      # Secure credential storage
└── Info.plist                # Permissions & app metadata
```

**Key Technologies:**
- **SwiftUI** - Native macOS interface
- **AVFoundation** - High-quality audio recording
- **Carbon Framework** - System-wide hotkey registration
- **Security Framework** - Keychain encryption
- **URLSession** - Secure API communication

## 🔒 Privacy & Security

**Your privacy is paramount:**
- ✅ Audio only processed for transcription
- ✅ No permanent audio storage
- ✅ API keys encrypted in Keychain
- ✅ All communication over HTTPS
- ✅ Follows OpenAI's privacy guidelines
- ✅ No telemetry or tracking

## 🤝 Contributing

We welcome contributions! TranscribeToggle is built with love for the developer community.

## 📄 License

MIT License - feel free to use, modify, and distribute.

---

**Made with ❤️ for productivity enthusiasts who believe their voice should be heard... as text.**