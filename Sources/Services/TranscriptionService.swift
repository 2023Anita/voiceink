import Foundation

protocol TranscriptionService {
    func transcribe(audioURL: URL) async throws -> String
}

class WhisperTranscriptionService: TranscriptionService {
    private let settings = SettingsStore.shared
    
    enum TranscriptionError: Error {
        case noAPIKey
        case invalidResponse
        case networkError(Error)
    }
    
    func transcribe(audioURL: URL) async throws -> String {
        guard let apiKey = settings.openAIAPIKey, !apiKey.isEmpty else {
            throw TranscriptionError.noAPIKey
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let audioData = try Data(contentsOf: audioURL)
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        
        if let language = settings.language, !language.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(language)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw TranscriptionError.invalidResponse
            }
            
            let json = try JSONDecoder().decode(WhisperResponse.self, from: data)
            return json.text
        } catch {
            throw TranscriptionError.networkError(error)
        }
    }
}

class StubTranscriptionService: TranscriptionService {
    func transcribe(audioURL: URL) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return "This is a stub transcription for testing purposes without API keys. Um, it contains some filler words, you know, and maybe some repetition repetition to demonstrate the polish feature."
    }
}

struct WhisperResponse: Codable {
    let text: String
}
