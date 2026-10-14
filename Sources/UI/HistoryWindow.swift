import SwiftUI
import AppKit

class HistoryWindow {
    private var window: NSWindow?
    
    func show() {
        if window == nil {
            let contentView = HistoryView()
            
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window?.title = "VoiceInk History"
            window?.contentView = NSHostingView(rootView: contentView)
            window?.center()
        }
        
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct HistoryView: View {
    @State private var entries: [HistoryStore.HistoryEntry] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading history...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No history yet")
                        .font(.title2)
                    Text("Your dictation history will appear here")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(entries, id: \.id) { entry in
                        HistoryEntryRow(entry: entry, onDelete: {
                            deleteEntry(entry)
                        })
                    }
                }
            }
            
            Divider()
            
            HStack {
                Button("Clear All") {
                    clearAll()
                }
                .disabled(entries.isEmpty)
                
                Spacer()
                
                Button("Refresh") {
                    loadHistory()
                }
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear {
            loadHistory()
        }
    }
    
    private func loadHistory() {
        isLoading = true
        Task {
            do {
                let fetched = try await HistoryStore.shared.fetchRecent(limit: 100)
                await MainActor.run {
                    entries = fetched
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func deleteEntry(_ entry: HistoryStore.HistoryEntry) {
        guard let id = entry.id else { return }
        Task {
            try? await HistoryStore.shared.deleteEntry(id: id)
            loadHistory()
        }
    }
    
    private func clearAll() {
        Task {
            try? await HistoryStore.shared.clearAll()
            loadHistory()
        }
    }
}

struct HistoryEntryRow: View {
    let entry: HistoryStore.HistoryEntry
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    copyToClipboard(entry.polishedText)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
            
            Text(entry.polishedText)
                .font(.body)
                .lineLimit(3)
            
            if entry.originalText != entry.polishedText {
                DisclosureGroup("Original") {
                    Text(entry.originalText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
