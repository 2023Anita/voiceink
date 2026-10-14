import Foundation
import Security

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @Published var useStubMode: Bool {
        didSet { UserDefaults.standard.set(useStubMode, forKey: "useStubMode") }
    }
    
    @Published var polishEnabled: Bool {
        didSet { UserDefaults.standard.set(polishEnabled, forKey: "polishEnabled") }
    }
    
    @Published var tone: String? {
        didSet { UserDefaults.standard.set(tone, forKey: "tone") }
    }
    
    @Published var language: String? {
        didSet { UserDefaults.standard.set(language, forKey: "language") }
    }
    
    var openAIAPIKey: String? {
        get { KeychainHelper.load(key: "openai_api_key") }
        set {
            if let value = newValue {
                KeychainHelper.save(key: "openai_api_key", value: value)
            } else {
                KeychainHelper.delete(key: "openai_api_key")
            }
        }
    }
    
    private let environment = ProcessInfo.processInfo.environment

    var apiBaseURL: URL {
        environment["OPENAI_API_BASE"].flatMap(URL.init(string:)) ?? URL(string: "https://api.openai.com/v1")!
    }

    var transcriptionModel: String { environment["VOICEINK_STT_MODEL"] ?? "whisper-1" }

    var polishModel: String { environment["VOICEINK_POLISH_MODEL"] ?? "gpt-4o-mini" }

    private init() {
        self.useStubMode = UserDefaults.standard.bool(forKey: "useStubMode")
        self.polishEnabled = UserDefaults.standard.object(forKey: "polishEnabled") as? Bool ?? true
        self.tone = UserDefaults.standard.string(forKey: "tone")
        self.language = UserDefaults.standard.string(forKey: "language")
    }
}

struct KeychainHelper {
    static func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
