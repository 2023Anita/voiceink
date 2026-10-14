# Building on macOS

This document provides detailed instructions for building VoiceInk on your Mac.

## System Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Command Line Tools installed
- At least 2 GB free disk space

## Installing Xcode

If you don't have Xcode:

1. Open the App Store
2. Search for "Xcode"
3. Click "Get" or "Install"
4. Wait 20-30 minutes for download (12+ GB)

After installation:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

## Building from Command Line

### 1. Clone and Navigate

```bash
git clone https://github.com/yourusername/VoiceInk.git
cd VoiceInk
```

### 2. Resolve Dependencies

```bash
swift package resolve
```

This downloads:
- KeyboardShortcuts (global hotkey support)
- GRDB (SQLite database wrapper)

### 3. Build

```bash
swift build -c release
```

The binary will be at: `.build/release/VoiceInk`

### 4. Run

```bash
.build/release/VoiceInk
```

**Important:** Command-line builds won't have proper app bundle structure, so:
- Menu bar icon may not show
- Permissions dialogs may not trigger
- Use Xcode for full functionality

## Building with Xcode (Recommended)

### 1. Open Project

```bash
cd VoiceInk
open Package.swift
```

Xcode will:
- Load the project
- Resolve dependencies automatically
- Set up build schemes

### 2. Configure Signing

1. Select the **VoiceInk** target (top left, near Run button)
2. Open the Project Navigator (⌘1)
3. Click **VoiceInk** under "Targets"
4. Go to **Signing & Capabilities** tab
5. Choose your **Team** from the dropdown
   - If you don't have a team, select your Apple ID
   - Xcode will create a free provisioning profile

### 3. Build

Press ⌘B or Product → Build

First build takes 2-3 minutes to compile dependencies.

### 4. Run

Press ⌘R or Product → Run

The app launches with:
- Menu bar icon visible
- Permission dialogs ready
- Full functionality enabled

## Creating a Distributable App

### For Personal Use (Free)

1. Product → Archive
2. Wait for archive to complete
3. In the Organizer window:
   - Click **Distribute App**
   - Choose **Copy App**
   - Click **Next** and **Export**
4. Move the app to `/Applications`

The app will only run on your Mac (free provisioning profile limitation).

### For Distribution (Paid Apple Developer Account)

1. Enroll in Apple Developer Program ($99/year)
2. Create an App ID in Developer Portal
3. Update signing in Xcode to use your team
4. Product → Archive
5. Distribute App → **Developer ID**
6. Sign and notarize

Notarization is required for apps distributed outside the App Store.

## Troubleshooting Builds

### "Package.resolved file is corrupted"

```bash
rm Package.resolved
swift package resolve
```

### "Failed to resolve dependencies"

Check internet connection, then:
```bash
swift package reset
swift package resolve
```

### "No such module 'KeyboardShortcuts'"

Dependencies didn't download. In Xcode:
1. File → Packages → Reset Package Caches
2. File → Packages → Resolve Package Versions

### Build Errors in AVFoundation

AVFoundation requires macOS. If you're seeing these errors:
- Ensure you're building for "My Mac" (not iOS Simulator)
- Check deployment target is macOS 13.0+

### "Command SwiftCompile failed"

1. Clean build folder: Product → Clean Build Folder (⌘⇧K)
2. Quit and restart Xcode
3. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

## Running Tests

### Command Line
```bash
swift test
```

### Xcode
Press ⌘U or Product → Test

Tests verify:
- Stub transcription service
- Passthrough polish service
- Settings persistence
- Keychain storage
- History database

## Build Configuration

### Debug Build (Default)
- Includes debug symbols
- No optimizations
- Larger binary size
- Better for development

```bash
swift build
```

### Release Build (Optimized)
- Optimizations enabled
- Smaller binary
- Faster execution
- Better for distribution

```bash
swift build -c release
```

## Architecture-Specific Notes

### Apple Silicon (M1/M2/M3)
VoiceInk builds natively for arm64. No special configuration needed.

### Intel Macs
Builds for x86_64 automatically. If you need universal binary:

```bash
swift build -c release --arch arm64 --arch x86_64
```

## Dependencies

### KeyboardShortcuts
- Version: 2.0.0+
- Purpose: Global hotkey registration
- License: MIT
- Repo: github.com/sindresorhus/KeyboardShortcuts

### GRDB.swift
- Version: 6.0.0+
- Purpose: SQLite database wrapper
- License: MIT
- Repo: github.com/groue/GRDB.swift

Both dependencies are fetched automatically by Swift Package Manager.

## Build Products

After a successful build, you'll find:

```
.build/
├── release/
│   └── VoiceInk              # Executable binary
└── debug/
    └── VoiceInk              # Debug binary
```

For Xcode builds:

```
~/Library/Developer/Xcode/DerivedData/VoiceInk-*/Build/Products/
├── Debug/
│   └── VoiceInk.app         # Debug app bundle
└── Release/
    └── VoiceInk.app         # Release app bundle
```

## Next Steps

After building successfully:
1. Follow [QUICKSTART.md](QUICKSTART.md) to run and configure
2. Read [README.md](README.md) for full documentation
3. Report build issues via GitHub Issues

---

**Build Status:** ✅ Builds successfully on macOS 13+ with Xcode 15+
