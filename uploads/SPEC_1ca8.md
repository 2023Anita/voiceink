# Typeless-like macOS MVP — Product Spec

Goal: Feature-parity **core** of Typeless for macOS desktop only (not a clone of proprietary code/assets). Working name: **VoiceInk** (placeholder; rename later).

## MVP scope (must ship)

1. **Global hotkey** (default: Right Option / configurable) — press to start recording, release (or press again) to stop.
2. **Microphone capture** → short audio file (wav/m4a).
3. **Speech-to-text** via pluggable provider:
   - Default: OpenAI Whisper API (or compatible) using user-supplied API key in Keychain / local settings.
   - Stub mode for UI testing without API key (fake transcript).
4. **AI polish** (LLM) that:
   - Removes filler (um/uh/you know)
   - Removes repetition
   - Honors mid-sentence self-corrections
   - Auto-formats spoken lists/steps
   - Optional: tone preset (neutral / email / chat)
5. **Inject text** into the currently focused app by simulating paste (clipboard save/restore + Cmd+V) and/or Accessibility typed string as fallback.
6. **Menu bar app** with: status (idle/recording/processing), settings (hotkey, API keys, language, polish on/off), history list (local only, SQLite or JSON).
7. **Permissions UX**: guide user to grant Microphone + Accessibility (+ Input Monitoring if needed).

## Explicitly OUT of MVP

- iOS/Android keyboard
- Windows/Linux
- Cloud account / subscription / team / SSO
- Ask Anything / web search actions
- Speak-to-edit selection rewriting (phase 2)
- Per-app tone profiles (phase 2)
- Real-time streaming partial transcripts (phase 2; MVP can be push-to-talk batch)
- Training on user data / cloud history sync

## Suggested stack

- **SwiftUI + AppKit** menu bar app (native, best for Accessibility & hotkeys)
- Hotkey: `KeyboardShortcuts` or Carbon/NSEvent global monitor
- Audio: `AVAudioRecorder` / `AVAudioEngine`
- STT: HTTP to Whisper-compatible endpoint
- Polish: HTTP to chat completions (OpenAI-compatible)
- Injection: `NSPasteboard` + `CGEvent` for Cmd+V; Accessibility as fallback
- Local history: SQLite via GRDB or simple JSON under Application Support
- Settings: `@AppStorage` + Keychain for secrets

If Swift toolchain unavailable in the agent environment, scaffold with **Tauri 2 + Rust** or **Electron + native module**, but prefer Swift if Xcode/macOS SDK is available on the worker.

## Architecture modules

```
App (MenuBar)
 ├─ HotkeyService
 ├─ AudioCaptureService
 ├─ TranscriptionService (protocol + WhisperClient + StubClient)
 ├─ PolishService (protocol + LLMClient + Passthrough)
 ├─ TextInjectionService
 ├─ HistoryStore
 └─ SettingsStore
```

Pipeline: Hotkey down → record → Hotkey up → transcribe → polish → inject → append history → restore clipboard.

## Acceptance criteria

- [ ] App builds on macOS (document exact Xcode / Swift version)
- [ ] Holding/toggling hotkey records and produces polished text
- [ ] Text lands in Notes / TextEdit / browser text field when focused
- [ ] Clipboard restored after injection
- [ ] Works offline in stub mode for demo without keys
- [ ] README: install, permissions, API keys, hotkey customization
- [ ] MIT or similar open license; no Typeless trademarks/assets

## Phase 2 (document only in README)

Speak-to-edit selection, Ask Anything panel, per-app tone, streaming STT, personal dictionary, translation mode.
