import SwiftUI
import AppKit
import KeyboardShortcuts

class SettingsWindow {
    private var window: NSWindow?
    
    func show() {
        if window == nil {
            let contentView = SettingsView()
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window?.title = "VoiceInk Settings"
            window?.contentView = NSHostingView(rootView: contentView)
            window?.center()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct SettingsView: View {
    @StateObject private var settings = SettingsStore.shared
    @State private var apiKey: String = ""
    @State private var showingAPIKey = false
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            APISettingsView(apiKey: $apiKey, showingAPIKey: $showingAPIKey)
                .tabItem {
                    Label("API Keys", systemImage: "key")
                }
            
            HotkeySettingsView()
                .tabItem {
                    Label("Hotkey", systemImage: "keyboard")
                }
        }
        .padding()
        .frame(width: 500, height: 500)
        .onAppear {
            if let key = settings.openAIAPIKey {
                apiKey = key
            }
        }
    }
}

struct GeneralSettingsView: View {
    @StateObject private var settings = SettingsStore.shared
    
    var body: some View {
        Form {
            Section("Processing") {
                Toggle("Enable AI Polish", isOn: $settings.polishEnabled)
                    .help("Use LLM to clean up filler words and improve text")
                
                Toggle("Use Stub Mode", isOn: $settings.useStubMode)
                    .help("Test without API keys (uses fake transcript)")
            }
            
            Section("Polish Settings") {
                Picker("Tone:", selection: Binding(
                    get: { settings.tone ?? "neutral" },
                    set: { settings.tone = $0 == "neutral" ? nil : $0 }
                )) {
                    Text("Neutral").tag("neutral")
                    Text("Email").tag("email")
                    Text("Chat").tag("chat")
                }
                .disabled(!settings.polishEnabled)
            }
            
            Section("Language") {
                TextField("Language (optional)", text: Binding(
                    get: { settings.language ?? "" },
                    set: { settings.language = $0.isEmpty ? nil : $0 }
                ))
                .help("e.g., 'en', 'es', 'fr' - leave blank for auto-detect")
            }
        }
        .formStyle(.grouped)
    }
}

struct APISettingsView: View {
    @Binding var apiKey: String
    @Binding var showingAPIKey: Bool
    @StateObject private var settings = SettingsStore.shared
    
    var body: some View {
        Form {
            Section {
                Text("Enter your OpenAI API key")
                    .font(.headline)
                
                Text("Your key is stored securely in the macOS Keychain")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                HStack {
                    if showingAPIKey {
                        TextField("API Key", text: $apiKey)
                    } else {
                        SecureField("API Key", text: $apiKey)
                    }
                    
                    Button(action: { showingAPIKey.toggle() }) {
                        Image(systemName: showingAPIKey ? "eye.slash" : "eye")
                    }
                }
                
                HStack {
                    Button("Save") {
                        settings.openAIAPIKey = apiKey.isEmpty ? nil : apiKey
                    }
                    
                    Button("Clear") {
                        apiKey = ""
                        settings.openAIAPIKey = nil
                    }
                    .foregroundColor(.red)
                }
            }
            
            Section {
                Link("Get an API key from OpenAI →", 
                     destination: URL(string: "https://platform.openai.com/api-keys")!)
            }
        }
        .formStyle(.grouped)
    }
}

struct HotkeySettingsView: View {
    var body: some View {
        Form {
            Section {
                Text("Global Hotkey")
                    .font(.headline)
                
                Text("Press this key to start/stop recording")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                KeyboardShortcuts.Recorder("Record Voice:", name: .recordVoice)
            }
            
            Section {
                Text("Tip: Use a key that's easy to reach while speaking")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
