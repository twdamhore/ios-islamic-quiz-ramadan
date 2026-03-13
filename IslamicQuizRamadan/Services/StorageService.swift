import Foundation

struct StorageService {

    private let defaults: UserDefaults

    enum Keys {
        static let players = "islamic_quiz_players"
        static let scores = "islamic_quiz_scores"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Player CRUD

    func addPlayer(name: String) -> Result<Player, StorageError> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure(.emptyPlayerName)
        }

        guard trimmed.count <= AppConstants.maxPlayerNameLength else {
            return .failure(.playerNameTooLong(trimmed.count))
        }

        var players = listPlayers()

        guard players.count < AppConstants.maxPlayers else {
            return .failure(.maxPlayersReached(AppConstants.maxPlayers))
        }

        let lowered = trimmed.lowercased()
        guard !players.contains(where: { $0.name.lowercased() == lowered }) else {
            return .failure(.duplicatePlayerName(trimmed))
        }

        let player = Player(name: trimmed)
        players.append(player)
        savePlayers(players)
        return .success(player)
    }

    func listPlayers() -> [Player] {
        guard let data = defaults.data(forKey: Keys.players) else { return [] }
        return (try? JSONDecoder().decode([Player].self, from: data)) ?? []
    }

    func deletePlayer(id: UUID) -> Result<Void, StorageError> {
        var players = listPlayers()
        guard let index = players.firstIndex(where: { $0.id == id }) else {
            return .failure(.playerNotFound(id))
        }
        players.remove(at: index)
        savePlayers(players)

        let scores = listScores().filter { $0.playerID != id }
        saveScores(scores)

        return .success(())
    }

    // MARK: - Score Persistence

    func saveScore(_ score: ScoreRecord) {
        var scores = listScores()
        scores.append(score)
        scores.sort(by: >)
        if scores.count > AppConstants.maxScores {
            scores = Array(scores.prefix(AppConstants.maxScores))
        }
        saveScores(scores)
    }

    func listScores() -> [ScoreRecord] {
        guard let data = defaults.data(forKey: Keys.scores) else { return [] }
        return (try? JSONDecoder().decode([ScoreRecord].self, from: data)) ?? []
    }

    // MARK: - Reset

    func resetAll() {
        defaults.removeObject(forKey: Keys.players)
        defaults.removeObject(forKey: Keys.scores)
    }

    // MARK: - Private

    private func savePlayers(_ players: [Player]) {
        guard let data = try? JSONEncoder().encode(players) else {
            assertionFailure("Failed to encode players")
            return
        }
        defaults.set(data, forKey: Keys.players)
    }

    private func saveScores(_ scores: [ScoreRecord]) {
        guard let data = try? JSONEncoder().encode(scores) else {
            assertionFailure("Failed to encode scores")
            return
        }
        defaults.set(data, forKey: Keys.scores)
    }
}
