import AVFoundation

@MainActor
final class SoundService {
    private var players: [String: AVAudioPlayer] = [:]

    init() {
        preload("correct")
        preload("wrong")
        preload("levelup")
    }

    func play(_ name: String) {
        players[name]?.currentTime = 0
        players[name]?.play()
    }

    private func preload(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") ??
              Bundle.main.url(forResource: name, withExtension: "wav") else {
            return
        }
        players[name] = try? AVAudioPlayer(contentsOf: url)
        players[name]?.prepareToPlay()
    }
}
