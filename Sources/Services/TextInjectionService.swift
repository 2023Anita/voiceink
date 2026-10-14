import Foundation
import AppKit
import ApplicationServices

class TextInjectionService {
    enum InjectionError: Error {
        case clipboardFailed
        case accessibilityDenied
        case injectionFailed
    }
    
    func inject(text: String) async throws {
        let originalClipboard = NSPasteboard.general.string(forType: .string)
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let success = simulateCommandV()
        
        if !success {
            try await fallbackAccessibilityType(text)
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if let original = originalClipboard {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(original, forType: .string)
        }
    }
    
    private func simulateCommandV() -> Bool {
        guard let eventSource = CGEventSource(stateID: .combinedSessionState) else {
            return false
        }
        
        let keyDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x09, keyDown: false)
        
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
        
        return true
    }
    
    private func fallbackAccessibilityType(_ text: String) async throws {
        guard AXIsProcessTrusted() else {
            throw InjectionError.accessibilityDenied
        }
        
        for char in text {
            let charString = String(char)
            guard let char = charString.utf16.first else { continue }
            
            if let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) {
                keyDownEvent.keyboardSetUnicodeString(stringLength: 1, unicodeString: [char])
                keyDownEvent.post(tap: .cghidEventTap)
            }
            
            if let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false) {
                keyUpEvent.keyboardSetUnicodeString(stringLength: 1, unicodeString: [char])
                keyUpEvent.post(tap: .cghidEventTap)
            }
            
            try await Task.sleep(nanoseconds: 5_000_000)
        }
    }
}
