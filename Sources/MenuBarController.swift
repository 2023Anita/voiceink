import AppKit
import SwiftUI
import KeyboardShortcuts

class MenuBarController: ObservableObject {
    private let statusItem: NSStatusItem
    private let pipeline: RecordingPipeline
    
    @Published var currentState: AppState = .idle
    
    enum AppState {
        case idle
        case recording
        case processing
        case error(String)
    }
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        self.pipeline = RecordingPipeline()
        
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
        
        let statusItem = NSMenuItem(title: "VoiceInk - Ready", action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "History", action: #selector(showHistory), keyEquivalent: "h"))
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(showSettings), keyEquivalent: ","))
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Permissions", action: #selector(showPermissions), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit VoiceInk", action: #selector(quit), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem.menu = menu
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
        guard currentState == .idle else { return }
        pipeline.startRecording()
    }
    
    private func stopRecording() {
        guard currentState == .recording else { return }
        pipeline.stopRecording()
    }
    
    private func updateState(_ state: AppState) {
        currentState = state
        updateMenuBarIcon()
        updateMenuTitle()
    }
    
    private func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }
        
        let iconName: String
        switch currentState {
        case .idle:
            iconName = "mic.circle"
        case .recording:
            iconName = "mic.circle.fill"
        case .processing:
            iconName = "hourglass"
        case .error:
            iconName = "exclamationmark.circle"
        }
        
        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "VoiceInk")
    }
    
    private func updateMenuTitle() {
        guard let menu = statusItem.menu, let firstItem = menu.items.first else { return }
        
        let title: String
        switch currentState {
        case .idle:
            title = "VoiceInk - Ready"
        case .recording:
            title = "VoiceInk - Recording..."
        case .processing:
            title = "VoiceInk - Processing..."
        case .error(let message):
            title = "VoiceInk - Error: \(message)"
        }
        
        firstItem.title = title
    }
    
    @objc private func showHistory() {
        let historyWindow = HistoryWindow()
        historyWindow.show()
    }
    
    @objc private func showSettings() {
        let settingsWindow = SettingsWindow()
        settingsWindow.show()
    }
    
    @objc private func showPermissions() {
        let permissionsWindow = PermissionsWindow()
        permissionsWindow.show()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension KeyboardShortcuts.Name {
    static let recordVoice = Self("recordVoice", default: .init(.rightOption))
}
