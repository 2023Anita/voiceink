# Quick Start Guide

This guide helps you get VoiceInk running on your Mac in under 5 minutes.

## Prerequisites

- Mac running macOS 13.0 (Ventura) or later
- Xcode 15.0 or later installed
- (Optional) OpenAI API key for real transcription

## Steps

### 1. Open the Project

```bash
cd /path/to/VoiceInk
open Package.swift
```

Xcode will open and resolve dependencies automatically (KeyboardShortcuts and GRDB).

### 2. Build and Run

In Xcode:
1. Wait for "Resolving Package Graph" to complete (bottom status bar)
2. Select the "VoiceInk" scheme (top left)
3. Press ⌘R (or Product → Run)

The first build takes 1-2 minutes to compile dependencies.

### 3. Grant Permissions

When the app launches:
1. A microphone icon appears in your menu bar
2. Click it → **Permissions**
3. Click "Grant Access" for:
   - **Microphone** (records your voice)
   - **Accessibility** (injects text into apps)

The Accessibility permission requires opening System Settings → Privacy & Security → Accessibility and enabling VoiceInk.

### 4. Configure (Choose One)

#### Option A: Stub Mode (No API Key)
Perfect for testing the UI and flow without API costs.

1. Click menu bar icon → **Settings** → **General**
2. Enable "**Use Stub Mode**"
3. Done! The app generates fake transcripts.

#### Option B: Real Transcription
1. Get an API key: [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Click menu bar icon → **Settings** → **API Keys**
3. Paste your key and click **Save**
4. In **General** settings, ensure "Use Stub Mode" is **OFF**

### 5. Try It

1. Open **Notes** or **TextEdit**
2. Click in a text field to focus it
3. **Press and hold Right Option** (⌥) key
4. **Speak**: "Hello world, this is a test"
5. **Release** the key
6. Wait 2-3 seconds
7. Polished text appears in your text field!

## Customization

### Change the Hotkey
1. Menu bar → **Settings** → **Hotkey**
2. Click the recorder field
3. Press your preferred key (e.g., Caps Lock, F13)

### Polish Settings
1. Menu bar → **Settings** → **General**
2. Toggle "Enable AI Polish" on/off
3. Choose tone: Neutral, Email, or Chat

### View History
1. Menu bar → **History**
2. See all your dictations with timestamps
3. Click copy icon to reuse any entry

## Troubleshooting

### "VoiceInk quit unexpectedly"
- Check Xcode console for error messages
- Ensure you've granted Microphone permission
- Try running from Xcode (⌘R) to see logs

### Hotkey doesn't work
- Ensure Accessibility permission is granted
- Check for hotkey conflicts with other apps
- Try a different key in Settings → Hotkey

### No text appears after dictation
- Verify the text field is **focused** (cursor blinking)
- Check Accessibility permission is granted
- Try clicking in the text field before using hotkey
- Open History to see if transcription worked

### "Invalid API Key" error
- Verify your OpenAI API key in Settings → API Keys
- Check your OpenAI account has credits
- Try Stub Mode first to isolate the issue

## What's Next?

- Read the full [README.md](README.md) for architecture details
- Check [SPEC.md](uploads/SPEC_1ca8.md) for original requirements
- Contribute improvements via pull requests
- Report bugs or feature requests via GitHub Issues

## Development Notes

### Running Tests
```bash
swift test
```

Or in Xcode: ⌘U (Product → Test)

### Building for Distribution
1. Product → Archive
2. Distribute App → Copy App
3. Sign with your Apple Developer certificate
4. Notarize for distribution (required for public release)

### Debugging
- Use Xcode's Console (⌘⇧Y) to see logs
- Set breakpoints in service files for step-through debugging
- Check `~/Library/Application Support/VoiceInk/` for database
- Audio recordings are in `/tmp/recording_*.m4a` during processing

---

**Ready to dictate?** Press Right Option and start speaking! 🎙️
