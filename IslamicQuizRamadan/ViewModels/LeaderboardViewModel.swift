import Foundation
import Observation

@Observable
@MainActor
final class LeaderboardViewModel {

    private let storage: StorageService
    private let currentPlayerID: UUID?

    private(set) var allScores: [ScoreRecord] = []
    private(set) var myScores: [ScoreRecord] = []

    init(storage: StorageService = StorageService(), currentPlayerID: UUID? = nil) {
        self.storage = storage
        self.currentPlayerID = currentPlayerID
        loadScores()
    }

    func loadScores() {
        let scores = storage.listScores().sorted(by: >)
        allScores = Array(scores.prefix(10))
        if let currentPlayerID {
            myScores = Array(scores.filter { $0.playerID == currentPlayerID }.prefix(10))
        } else {
            myScores = []
        }
    }
}
