import Foundation
import AVFoundation
import ApplicationServices

class PermissionManager {
    static let shared = PermissionManager()
    
    enum PermissionStatus {
        case granted
        case denied
        case notDetermined
    }
    
    private init() {}
    
    func checkAllPermissions() {
        Task {
            await checkMicrophonePermission()
            checkAccessibilityPermission()
        }
    }
    
    @MainActor
    func checkMicrophonePermission() async -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .audio)
            return granted ? .granted : .denied
        @unknown default:
            return .notDetermined
        }
    }
    
    func checkAccessibilityPermission() -> PermissionStatus {
        let trusted = AXIsProcessTrusted()
        return trusted ? .granted : .denied
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
    }
}
