import Foundation

class RecordingPipeline {
    private let audioCapture: AudioCaptureService
    private let transcription: TranscriptionService
    private let polish: PolishService
    private let injection: TextInjectionService
    private let history: HistoryStore
    private let settings: SettingsStore
    
    var onStateChange: ((MenuBarController.AppState) -> Void)?
    
    init() {
        self.audioCapture = AudioCaptureService()
        self.settings = SettingsStore.shared
        
        if settings.useStubMode {
            self.transcription = StubTranscriptionService()
        } else {
            self.transcription = WhisperTranscriptionService()
        }
        
        if settings.polishEnabled {
            self.polish = LLMPolishService()
        } else {
            self.polish = PassthroughPolishService()
        }
        
        self.injection = TextInjectionService()
        self.history = HistoryStore.shared
    }
    
    func startRecording() {
        onStateChange?(.recording)
        
        do {
            try audioCapture.startRecording()
        } catch {
            onStateChange?(.error("Failed to start recording: \(error.localizedDescription)"))
        }
    }
    
    func stopRecording() {
        onStateChange?(.processing)
        
        audioCapture.stopRecording { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let audioURL):
                self.processAudio(audioURL)
            case .failure(let error):
                self.onStateChange?(.error("Recording failed: \(error.localizedDescription)"))
            }
        }
    }
    
    private func processAudio(_ audioURL: URL) {
        Task {
            do {
                let transcript = try await transcription.transcribe(audioURL: audioURL)
                
                let polished = try await polish.polish(text: transcript, tone: settings.tone)
                
                try await injection.inject(text: polished)
                
                try await history.addEntry(
                    original: transcript,
                    polished: polished,
                    audioURL: audioURL
                )
                
                await MainActor.run {
                    self.onStateChange?(.idle)
                }
            } catch {
                await MainActor.run {
                    self.onStateChange?(.error("Processing failed: \(error.localizedDescription)"))
                }
            }
        }
    }
}
