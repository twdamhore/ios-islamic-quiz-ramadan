import Foundation
import Observation

@Observable
@MainActor
final class PlayerViewModel {

    private let storage: StorageService

    private(set) var players: [Player] = []
    var currentPlayerID: UUID? {
        didSet {
            if let currentPlayerID, !players.contains(where: { $0.id == currentPlayerID }) {
                self.currentPlayerID = nil
            }
        }
    }

    var currentPlayer: Player? {
        players.first { $0.id == currentPlayerID }
    }

    init(storage: StorageService = StorageService()) {
        self.storage = storage
        players = storage.listPlayers()
    }

    func addPlayer(name: String) -> Result<Player, StorageError> {
        let result = storage.addPlayer(name: name)
        if case .success = result {
            players = storage.listPlayers()
        }
        return result
    }

    enum DeleteError: Error, Equatable {
        case cannotDeleteCurrentPlayer
        case cannotDeleteSolePlayer
        case storageError(StorageError)
    }

    func deletePlayer(id: UUID) -> Result<Void, DeleteError> {
        if players.count <= 1 {
            return .failure(.cannotDeleteSolePlayer)
        }
        if id == currentPlayerID {
            return .failure(.cannotDeleteCurrentPlayer)
        }
        switch storage.deletePlayer(id: id) {
        case .success:
            players = storage.listPlayers()
            return .success(())
        case .failure(let error):
            return .failure(.storageError(error))
        }
    }
}
