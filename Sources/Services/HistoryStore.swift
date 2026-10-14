import Foundation
import GRDB

class HistoryStore {
    static let shared = HistoryStore()
    
    private var dbQueue: DatabaseQueue?
    
    struct HistoryEntry: Codable, FetchableRecord, PersistableRecord {
        var id: Int64?
        let timestamp: Date
        let originalText: String
        let polishedText: String
        let audioPath: String?
        
        static let databaseTableName = "history"
    }
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let appDir = appSupport.appendingPathComponent("VoiceInk", isDirectory: true)
            
            try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
            
            let dbPath = appDir.appendingPathComponent("history.db").path
            dbQueue = try DatabaseQueue(path: dbPath)
            
            try dbQueue?.write { db in
                try db.create(table: "history", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("timestamp", .datetime).notNull()
                    t.column("originalText", .text).notNull()
                    t.column("polishedText", .text).notNull()
                    t.column("audioPath", .text)
                }
            }
        } catch {
            print("Database setup failed: \(error)")
        }
    }
    
    func addEntry(original: String, polished: String, audioURL: URL?) async throws {
        guard let dbQueue = dbQueue else { return }
        
        let entry = HistoryEntry(
            id: nil,
            timestamp: Date(),
            originalText: original,
            polishedText: polished,
            audioPath: audioURL?.path
        )
        
        try await dbQueue.write { db in
            try entry.insert(db)
        }
    }
    
    func fetchRecent(limit: Int = 50) async throws -> [HistoryEntry] {
        guard let dbQueue = dbQueue else { return [] }
        
        return try await dbQueue.read { db in
            try HistoryEntry
                .order(Column("timestamp").desc)
                .limit(limit)
                .fetchAll(db)
        }
    }
    
    func deleteEntry(id: Int64) async throws {
        guard let dbQueue = dbQueue else { return }
        
        try await dbQueue.write { db in
            try HistoryEntry.deleteOne(db, key: id)
        }
    }
    
    func clearAll() async throws {
        guard let dbQueue = dbQueue else { return }
        
        try await dbQueue.write { db in
            try HistoryEntry.deleteAll(db)
        }
    }
}
