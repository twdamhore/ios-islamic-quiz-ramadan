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

        guard trimmed.count <= 20 else {
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
        return .success(())
    }

    // MARK: - Private

    private func savePlayers(_ players: [Player]) {
        if let data = try? JSONEncoder().encode(players) {
            defaults.set(data, forKey: Keys.players)
        }
    }
}
