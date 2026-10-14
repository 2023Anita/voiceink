import Foundation

protocol PolishService {
    func polish(text: String, tone: String?) async throws -> String
}

class LLMPolishService: PolishService {
    private let settings = SettingsStore.shared
    
    enum PolishError: Error {
        case noAPIKey
        case invalidResponse
        case networkError(Error)
    }
    
    func polish(text: String, tone: String?) async throws -> String {
        guard let apiKey = settings.openAIAPIKey, !apiKey.isEmpty else {
            throw PolishError.noAPIKey
        }
        
        let systemPrompt = buildSystemPrompt(tone: tone)
        
        var request = URLRequest(url: settings.apiBaseURL.appendingPathComponent("chat/completions"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": settings.polishModel,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PolishError.invalidResponse
            }
            
            let json = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            return json.choices.first?.message.content ?? text
        } catch {
            throw PolishError.networkError(error)
        }
    }
    
    private func buildSystemPrompt(tone: String?) -> String {
        var prompt = """
        You are a text polishing assistant. Your job is to clean up dictated text:
        
        1. Remove filler words (um, uh, like, you know, etc.)
        2. Remove repetitions where the speaker clearly repeated themselves
        3. Honor self-corrections (e.g., "go to the store no wait the bank" → "go to the bank")
        4. Format spoken lists and numbered steps properly
        5. Fix obvious grammar and punctuation
        6. Preserve the speaker's intent and meaning exactly
        
        """
        
        if let tone = tone {
            switch tone {
            case "email":
                prompt += "Format the output as professional email text.\n"
            case "chat":
                prompt += "Format the output as casual chat message text.\n"
            default:
                prompt += "Keep a neutral, natural tone.\n"
            }
        } else {
            prompt += "Keep a neutral, natural tone.\n"
        }
        
        prompt += "\nReturn ONLY the polished text, no explanations or meta-commentary."
        
        return prompt
    }
}

class PassthroughPolishService: PolishService {
    func polish(text: String, tone: String?) async throws -> String {
        return text
    }
}

/// Offline polisher used in stub mode: strips common fillers and immediate word repeats.
/// It does not attempt self-corrections or list formatting; those need the LLM.
struct RuleBasedPolishService: PolishService {
    private static let fillerPatterns = [
        #"\b(um+|uh+|erm|hmm)\b,?\s*"#,
        #"\byou know,?\s*"#,
        #"\bI mean,?\s*"#
    ]

    func polish(text: String, tone: String?) async throws -> String {
        Self.clean(text)
    }

    static func clean(_ text: String) -> String {
        var result = text
        for pattern in fillerPatterns {
            result = result.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
        }
        result = result.replacingOccurrences(of: #"\b(\w+)(\s+\1\b)+"#, with: "$1", options: [.regularExpression, .caseInsensitive])
        result = result.replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
        result = result.replacingOccurrences(of: #"\s+([,.!?])"#, with: "$1", options: .regularExpression)
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        if let first = result.first {
            result = first.uppercased() + result.dropFirst()
        }
        return result
    }
}

struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}
