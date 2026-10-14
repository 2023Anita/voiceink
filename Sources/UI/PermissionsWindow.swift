import SwiftUI
import AppKit

class PermissionsWindow {
    private var window: NSWindow?
    
    func show() {
        if window == nil {
            let contentView = PermissionsView()
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window?.title = "VoiceInk Permissions"
            window?.contentView = NSHostingView(rootView: contentView)
            window?.center()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct PermissionsView: View {
    @State private var micStatus: PermissionManager.PermissionStatus = .notDetermined
    @State private var accessibilityStatus: PermissionManager.PermissionStatus = .notDetermined
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("VoiceInk Permissions")
                .font(.title)
            
            Text("VoiceInk needs the following permissions to work:")
                .font(.body)
                .foregroundColor(.secondary)
            
            Divider()
            
            PermissionRow(
                icon: "mic.fill",
                title: "Microphone Access",
                description: "Required to record your voice",
                status: micStatus,
                action: {
                    Task {
                        micStatus = await PermissionManager.shared.checkMicrophonePermission()
                    }
                }
            )
            
            PermissionRow(
                icon: "accessibility",
                title: "Accessibility Access",
                description: "Required to inject text into other apps",
                status: accessibilityStatus,
                action: {
                    PermissionManager.shared.requestAccessibilityPermission()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        accessibilityStatus = PermissionManager.shared.checkAccessibilityPermission()
                    }
                }
            )
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Check Status") {
                    checkAllPermissions()
                }
            }
        }
        .padding()
        .frame(width: 500, height: 400)
        .onAppear {
            checkAllPermissions()
        }
    }
    
    private func checkAllPermissions() {
        Task {
            micStatus = await PermissionManager.shared.checkMicrophonePermission()
            accessibilityStatus = PermissionManager.shared.checkAccessibilityPermission()
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionManager.PermissionStatus
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(statusColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    statusBadge
                    
                    if status != .granted {
                        Button("Grant Access") {
                            action()
                        }
                        .buttonStyle(.link)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .granted: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusText: String {
        switch status {
        case .granted: return "Granted"
        case .denied: return "Denied"
        case .notDetermined: return "Not Set"
        }
    }
}
