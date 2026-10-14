import Foundation
import AVFoundation

class AudioCaptureService {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    enum AudioError: Error {
        case permissionDenied
        case setupFailed
        case recordingFailed
    }
    
    func startRecording() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
        recordingURL = tempDir.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        guard let url = recordingURL else {
            throw AudioError.setupFailed
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
        } catch {
            throw AudioError.recordingFailed
        }
    }
    
    func stopRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let recorder = audioRecorder, let url = recordingURL else {
            completion(.failure(AudioError.recordingFailed))
            return
        }
        
        recorder.stop()
        
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false)
        
        if FileManager.default.fileExists(atPath: url.path) {
            completion(.success(url))
        } else {
            completion(.failure(AudioError.recordingFailed))
        }
        
        audioRecorder = nil
    }
}
