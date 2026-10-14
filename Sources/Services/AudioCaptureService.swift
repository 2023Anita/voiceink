import Foundation
import AVFoundation

final class AudioCaptureService {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    enum AudioError: LocalizedError {
        case setupFailed
        case recordingFailed

        var errorDescription: String? {
            switch self {
            case .setupFailed: return "Could not prepare the recorder"
            case .recordingFailed: return "Recording failed (check Microphone permission)"
            }
        }
    }

    func startRecording() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("voiceink_\(Int(Date().timeIntervalSince1970)).m4a")
        recordingURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16_000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            guard recorder.record() else { throw AudioError.recordingFailed }
            audioRecorder = recorder
        } catch let error as AudioError {
            throw error
        } catch {
            throw AudioError.setupFailed
        }
    }

    func stopRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        guard let recorder = audioRecorder, let url = recordingURL else {
            completion(.failure(AudioError.recordingFailed))
            return
        }

        recorder.stop()
        audioRecorder = nil

        if FileManager.default.fileExists(atPath: url.path) {
            completion(.success(url))
        } else {
            completion(.failure(AudioError.recordingFailed))
        }
    }
}
