import AVFoundation

enum SoundEffect: String, CaseIterable {
    case correct
    case wrong
    case levelUp = "levelup"
}

@MainActor
final class SoundService {
    private var players: [SoundEffect: AVAudioPlayer] = [:]

    init() {
        configureAudioSession()
        for effect in SoundEffect.allCases {
            preload(effect)
        }
    }

    func play(_ effect: SoundEffect) {
        guard let player = players[effect] else { return }
        player.stop()
        player.currentTime = 0
        player.play()
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
    }

    private func preload(_ effect: SoundEffect) {
        let extensions = ["caf", "mp3", "wav"]
        var url: URL?
        for ext in extensions {
            if let found = Bundle.main.url(forResource: effect.rawValue, withExtension: ext) {
                url = found
                break
            }
        }
        guard let url else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[effect] = player
        } catch {
            assertionFailure("Failed to load sound \(effect.rawValue): \(error)")
        }
    }
}
