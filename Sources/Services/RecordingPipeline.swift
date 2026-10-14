import Foundation

final class RecordingPipeline {
    private let audioCapture = AudioCaptureService()
    private let injection = TextInjectionService()
    private let history = HistoryStore.shared
    private let settings = SettingsStore.shared

    var onStateChange: ((MenuBarController.AppState) -> Void)?

    // Resolved per run so Settings changes apply without restarting the app.
    private var transcription: TranscriptionService {
        settings.useStubMode ? StubTranscriptionService() : WhisperTranscriptionService()
    }

    private var polish: PolishService {
        guard settings.polishEnabled else { return PassthroughPolishService() }
        return settings.useStubMode ? RuleBasedPolishService() : LLMPolishService()
    }

    func startRecording() {
        do {
            try audioCapture.startRecording()
            onStateChange?(.recording)
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
    }

    func stopRecording() {
        onStateChange?(.processing)

        audioCapture.stopRecording { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let audioURL):
                self.processAudio(audioURL)
            case .failure(let error):
                self.onStateChange?(.error(error.localizedDescription))
            }
        }
    }

    private func processAudio(_ audioURL: URL) {
        let transcription = self.transcription
        let polish = self.polish
        let tone = settings.tone

        Task {
            defer { try? FileManager.default.removeItem(at: audioURL) }
            do {
                let transcript = try await transcription.transcribe(audioURL: audioURL)
                let polished = try await polish.polish(text: transcript, tone: tone)
                try await injection.inject(text: polished)
                try await history.addEntry(original: transcript, polished: polished, audioURL: nil)
                onStateChange?(.idle)
            } catch {
                onStateChange?(.error(error.localizedDescription))
            }
        }
    }
}
