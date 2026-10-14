import AppKit
import SwiftUI
import KeyboardShortcuts

final class MenuBarController: NSObject, ObservableObject {
    enum AppState: Equatable {
        case idle
        case recording
        case processing
        case error(String)
    }

    private let statusItem: NSStatusItem
    private let pipeline = RecordingPipeline()
    private let statusMenuItem = NSMenuItem(title: "VoiceInk - Ready", action: nil, keyEquivalent: "")

    private lazy var historyWindow = HistoryWindow()
    private lazy var settingsWindow = SettingsWindow()
    private lazy var permissionsWindow = PermissionsWindow()

    @Published private(set) var currentState: AppState = .idle

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        super.init()

        setupMenu()
        setupHotkey()

        pipeline.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.updateState(state)
            }
        }
    }

    private func setupMenu() {
        let menu = NSMenu()

        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(.separator())
        menu.addItem(makeItem("History", #selector(showHistory), "h"))
        menu.addItem(makeItem("Settings…", #selector(showSettings), ","))
        menu.addItem(makeItem("Permissions…", #selector(showPermissions), ""))
        menu.addItem(.separator())
        menu.addItem(makeItem("Quit VoiceInk", #selector(quit), "q"))

        statusItem.menu = menu
    }

    private func makeItem(_ title: String, _ action: Selector, _ key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    private func setupHotkey() {
        KeyboardShortcuts.onKeyDown(for: .recordVoice) { [weak self] in
            self?.startRecording()
        }
        KeyboardShortcuts.onKeyUp(for: .recordVoice) { [weak self] in
            self?.stopRecording()
        }
    }

    private func startRecording() {
        switch currentState {
        case .idle, .error:
            pipeline.startRecording()
        case .recording, .processing:
            return
        }
    }

    private func stopRecording() {
        guard currentState == .recording else { return }
        pipeline.stopRecording()
    }

    private func updateState(_ state: AppState) {
        currentState = state

        let iconName: String
        let title: String
        switch state {
        case .idle:
            iconName = "mic.circle"
            title = "VoiceInk - Ready"
        case .recording:
            iconName = "mic.circle.fill"
            title = "VoiceInk - Recording…"
        case .processing:
            iconName = "hourglass"
            title = "VoiceInk - Processing…"
        case .error(let message):
            iconName = "exclamationmark.circle"
            title = "Error: \(message)"
        }

        statusItem.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "VoiceInk")
        statusMenuItem.title = title
    }

    @objc private func showHistory() { historyWindow.show() }
    @objc private func showSettings() { settingsWindow.show() }
    @objc private func showPermissions() { permissionsWindow.show() }
    @objc private func quit() { NSApplication.shared.terminate(nil) }
}

extension KeyboardShortcuts.Name {
    // KeyboardShortcuts cannot register modifier-only shortcuts (e.g. Right Option alone),
    // so the default is Option+Space; users can rebind it in Settings → Hotkey.
    static let recordVoice = Self("recordVoice", default: .init(.space, modifiers: [.option]))
}
