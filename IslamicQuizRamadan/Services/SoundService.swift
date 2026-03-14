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
        for effect in SoundEffect.allCases {
            preload(effect)
        }
    }

    func play(_ effect: SoundEffect) {
        players[effect]?.currentTime = 0
        players[effect]?.play()
    }

    private func preload(_ effect: SoundEffect) {
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") ??
              Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") else {
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[effect] = player
        } catch {
            assertionFailure("Failed to load sound \(effect.rawValue): \(error)")
        }
    }
}
