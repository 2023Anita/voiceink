# VoiceInk

> Open-source macOS menu bar app for AI-powered voice dictation with text polishing and smart injection.

VoiceInk recreates the core experience of AI voice dictation tools: press a hotkey, speak naturally, and have polished text instantly injected into any focused application. It removes filler words, honors self-corrections, and formats your speech professionally.

## Features

- **Global hotkey push-to-talk** (default: Right Option key, configurable)
- **Speech-to-text** via OpenAI Whisper API (or compatible endpoint)
- **AI text polishing** that:
  - Removes filler words (um, uh, like, you know)
  - Eliminates repetitions
  - Honors self-corrections ("go to store no wait the bank" → "go to the bank")
  - Auto-formats lists and numbered steps
  - Optional tone presets (neutral, email, chat)
- **Smart text injection** into any focused app (clipboard + Cmd+V with Accessibility fallback)
- **Menu bar interface** showing status (idle/recording/processing)
- **Local history** with original and polished text (SQLite storage)
- **Stub mode** for testing without API keys
- **Secure credential storage** via macOS Keychain

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building)
- Swift 5.9+
- OpenAI API key (optional for stub mode)

## Installation

### Building from Source

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/VoiceInk.git
   cd VoiceInk
   ```

2. **Install dependencies:**
   ```bash
   swift package resolve
   ```

3. **Build the project:**
   ```bash
   swift build -c release
   ```

   Or open in Xcode:
   ```bash
   open Package.swift
   ```
   Then: Product → Build (⌘B)

4. **Run the app:**
   ```bash
   swift run
   ```

   Or from Xcode: Product → Run (⌘R)

### Distribution Build

To create a distributable .app bundle:

1. Open the project in Xcode
2. Select the VoiceInk scheme
3. Product → Archive
4. Export the app bundle
5. Optionally sign with your Apple Developer certificate

**Note:** For distribution outside the App Store, you'll need to notarize the app with Apple.

## Setup

### 1. Grant Permissions

VoiceInk requires two macOS permissions:

- **Microphone Access:** Required to record your voice
- **Accessibility Access:** Required to inject text into other applications

On first launch, the app will guide you through granting these permissions. You can also access the Permissions window from the menu bar → Permissions.

### 2. Configure API Key

#### Option A: Use Real Transcription (Recommended)

1. Get an OpenAI API key from [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Click the VoiceInk menu bar icon → Settings → API Keys
3. Enter your API key and click Save
4. The key is stored securely in your macOS Keychain
5. Disable "Use Stub Mode" in General settings

#### Option B: Use Stub Mode (Testing)

1. Click the VoiceInk menu bar icon → Settings → General
2. Enable "Use Stub Mode"
3. No API key required; the app will generate fake transcripts for testing

### 3. Customize Hotkey (Optional)

1. Click the VoiceInk menu bar icon → Settings → Hotkey
2. Click the recorder field
3. Press your desired key combination
4. Default is Right Option (⌥)

## Usage

### Basic Dictation

1. **Focus the target application** (Notes, TextEdit, browser text field, etc.)
2. **Press and hold** the hotkey (default: Right Option)
3. **Speak naturally** - the menu bar icon shows recording status
4. **Release the hotkey** to stop recording
5. Wait a moment while the app processes your speech
6. Polished text appears in your focused application

### Settings

- **Enable AI Polish:** Toggle text polishing on/off (keep fillers if off)
- **Tone:** Choose neutral, email, or chat formatting
- **Language:** Specify language code (e.g., "en", "es", "fr") or leave blank for auto-detect

### History

Click the menu bar icon → History to view:
- All past dictations with timestamps
- Original transcripts vs. polished output
- Copy any entry to clipboard
- Delete individual entries or clear all

## Environment Variables (Optional)

For advanced configuration, you can set:

```bash
# Use a custom OpenAI-compatible API endpoint
export OPENAI_API_BASE="https://your-endpoint.com/v1"
```

The default endpoint is `https://api.openai.com/v1`.

## Architecture

VoiceInk is built with clean separation of concerns:

```
App (MenuBar)
 ├─ HotkeyService          # Global hotkey monitoring
 ├─ AudioCaptureService    # Microphone recording
 ├─ TranscriptionService   # Speech-to-text (Whisper/Stub)
 ├─ PolishService          # LLM text polishing (GPT/Passthrough)
 ├─ TextInjectionService   # Clipboard + Accessibility injection
 ├─ HistoryStore           # SQLite history storage
 └─ SettingsStore          # UserDefaults + Keychain
```

**Pipeline flow:**
1. Hotkey down → start recording
2. Hotkey up → stop recording
3. Transcribe audio → raw text
4. Polish text → cleaned text
5. Save clipboard → inject text → restore clipboard
6. Append to history

## Acceptance Checklist

- [x] App builds on macOS 13+ with Xcode 15+
- [x] Global hotkey triggers recording (push-to-talk or toggle)
- [x] Audio captured and sent to Whisper API
- [x] LLM polishes text (removes fillers, honors corrections, formats lists)
- [x] Text injected into focused app (Notes, TextEdit, browser)
- [x] Original clipboard content restored after injection
- [x] Works offline in stub mode without API keys
- [x] Menu bar shows status: idle/recording/processing/error
- [x] Settings UI for hotkey, API keys, language, polish toggle
- [x] History UI with local SQLite storage
- [x] Permission onboarding for Microphone + Accessibility
- [x] README with build instructions and usage guide
- [x] API keys stored in Keychain (never committed)
- [x] MIT license with no proprietary trademarks

## Development

### Running Tests

```bash
swift test
```

### Project Structure

```
VoiceInk/
├── Sources/
│   ├── VoiceInkApp.swift              # App entry point
│   ├── MenuBarController.swift        # Menu bar UI and hotkey
│   ├── Services/
│   │   ├── RecordingPipeline.swift    # Main orchestration
│   │   ├── AudioCaptureService.swift  # Recording
│   │   ├── TranscriptionService.swift # Whisper + Stub
│   │   ├── PolishService.swift        # LLM + Passthrough
│   │   ├── TextInjectionService.swift # Clipboard + Accessibility
│   │   ├── HistoryStore.swift         # SQLite history
│   │   ├── SettingsStore.swift        # Settings + Keychain
│   │   └── PermissionManager.swift    # Permission checks
│   └── UI/
│       ├── HistoryWindow.swift        # History browser
│       ├── SettingsWindow.swift       # Settings panel
│       └── PermissionsWindow.swift    # Permission guide
├── Tests/
│   └── VoiceInkTests/
├── Info.plist                         # Bundle info + permissions
├── Package.swift                      # Swift Package Manager
├── README.md
└── LICENSE
```

### Code Signing (Required for Distribution)

1. Open the project in Xcode
2. Select the VoiceInk target
3. Go to Signing & Capabilities
4. Select your Apple Developer Team
5. Enable "Automatically manage signing"

For local development without a paid Apple Developer account, you can use a free provisioning profile, but the app will only run on your machine.

### Debugging Tips

- **Hotkey not working:** Check that the app has Accessibility permissions in System Settings → Privacy & Security → Accessibility
- **Microphone not recording:** Verify Microphone permission granted in System Settings → Privacy & Security → Microphone
- **Text not injecting:** Try the Accessibility fallback by ensuring the app is trusted
- **API errors:** Check your API key in Settings and verify your OpenAI account has credits

## Phase 2 (Future)

Potential future enhancements (documented only, not implemented):

- Speak-to-edit: Select text and re-dictate to replace it
- Ask Anything: Command panel for web search and AI queries
- Per-app tone profiles: Automatic tone switching based on focused app
- Streaming STT: Real-time partial transcripts (currently batch-only)
- Personal dictionary: Custom vocabulary and abbreviations
- Translation mode: Dictate in one language, output another
- Cloud sync: Optional history sync across devices
- Custom hotkey actions: Different keys for different tones

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

Please ensure your code:
- Follows Swift style guidelines
- Includes tests for new functionality
- Maintains backward compatibility
- Does not include API keys or secrets

## Security

- **API keys are stored in macOS Keychain**, never in code or config files
- Local history is stored unencrypted in `~/Library/Application Support/VoiceInk/`
- Audio recordings are temporarily stored in `/tmp` and deleted after processing
- No telemetry or data sent to third parties (except OpenAI API for transcription/polish)

## License

MIT License - see LICENSE file for details.

**This project is not affiliated with or endorsed by Typeless or any other commercial dictation software.** VoiceInk is an independent open-source implementation of voice dictation features.

## Troubleshooting

### "VoiceInk can't be opened because Apple cannot check it for malicious software"

This happens with unsigned apps. Right-click the app → Open → Open anyway.

Or use the command line:
```bash
xattr -cr /path/to/VoiceInk.app
```

### Hotkey Conflicts

If another app uses the same hotkey:
1. Open Settings → Hotkey
2. Choose a different key combination
3. Avoid system shortcuts (⌘Space, ⌘Tab, etc.)

### Poor Transcription Quality

- Speak clearly and at a moderate pace
- Ensure you're in a quiet environment
- Check your microphone input level in System Settings
- Try specifying your language in Settings → General → Language

### Text Injected in Wrong Place

- Ensure the target text field is **focused** (cursor blinking)
- Some apps may not support clipboard injection
- Try clicking in the text field before using the hotkey

## Credits

Built with:
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by Sindre Sorhus
- [GRDB.swift](https://github.com/groue/GRDB.swift) by Gwendal Roué
- OpenAI Whisper and GPT APIs

---

**VoiceInk** — Your voice, refined.
