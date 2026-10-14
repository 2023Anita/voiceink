import XCTest
@testable import VoiceInk

final class VoiceInkTests: XCTestCase {
    func testStubTranscriptionService() async throws {
        let service = StubTranscriptionService()
        let tempURL = URL(fileURLWithPath: "/tmp/test.m4a")
        
        let result = try await service.transcribe(audioURL: tempURL)
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("stub"))
    }
    
    func testPassthroughPolishService() async throws {
        let service = PassthroughPolishService()
        let input = "um hello world you know"
        
        let result = try await service.polish(text: input, tone: nil)
        
        XCTAssertEqual(result, input, "Passthrough should not modify text")
    }
    
    func testSettingsStore() {
        let settings = SettingsStore()
        
        settings.useStubMode = true
        XCTAssertTrue(settings.useStubMode)
        
        settings.polishEnabled = false
        XCTAssertFalse(settings.polishEnabled)
        
        settings.tone = "email"
        XCTAssertEqual(settings.tone, "email")
    }
    
    func testKeychainHelper() {
        let testKey = "test_key_\(UUID().uuidString)"
        let testValue = "test_value"
        
        KeychainHelper.save(key: testKey, value: testValue)
        
        let retrieved = KeychainHelper.load(key: testKey)
        XCTAssertEqual(retrieved, testValue)
        
        KeychainHelper.delete(key: testKey)
        
        let deleted = KeychainHelper.load(key: testKey)
        XCTAssertNil(deleted)
    }
    
    func testHistoryStore() async throws {
        let store = HistoryStore.shared
        
        try await store.addEntry(
            original: "um hello",
            polished: "hello",
            audioURL: nil
        )
        
        let entries = try await store.fetchRecent(limit: 10)
        XCTAssertFalse(entries.isEmpty)
        
        let lastEntry = entries.first!
        XCTAssertEqual(lastEntry.originalText, "um hello")
        XCTAssertEqual(lastEntry.polishedText, "hello")
    }
}
