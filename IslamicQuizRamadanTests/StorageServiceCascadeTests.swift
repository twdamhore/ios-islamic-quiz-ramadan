import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("StorageService – Cascade Delete & Reset", .serialized)
struct StorageServiceCascadeTests {

    private let suiteName = "StorageServiceCascadeTests"

    private func makeService() -> StorageService {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return StorageService(defaults: defaults)
    }

    private func makeScore(
        playerID: UUID,
        playerName: String = "Test",
        totalCorrect: Int = 5,
        completionTimeSeconds: TimeInterval = 100
    ) -> ScoreRecord {
        ScoreRecord(
            playerID: playerID,
            playerName: playerName,
            totalCorrect: totalCorrect,
            completionTimeSeconds: completionTimeSeconds
        )
    }

    // MARK: - Cascade Delete

    @Test("Deleting a player removes their scores")
    func cascadeDeleteRemovesScores() {
        let service = makeService()
        guard case .success(let player) = service.addPlayer(name: "Ahmad") else {
            Issue.record("Expected success")
            return
        }

        service.saveScore(makeScore(playerID: player.id, playerName: "Ahmad"))
        service.saveScore(makeScore(playerID: player.id, playerName: "Ahmad", totalCorrect: 8))

        _ = service.deletePlayer(id: player.id)

        #expect(service.listScores().isEmpty)
    }

    @Test("Cascade delete does not affect other players' scores")
    func cascadeDeletePreservesOtherScores() {
        let service = makeService()
        guard case .success(let ahmad) = service.addPlayer(name: "Ahmad"),
              case .success(let fatimah) = service.addPlayer(name: "Fatimah") else {
            Issue.record("Expected success")
            return
        }

        service.saveScore(makeScore(playerID: ahmad.id, playerName: "Ahmad"))
        service.saveScore(makeScore(playerID: ahmad.id, playerName: "Ahmad", totalCorrect: 9))
        service.saveScore(makeScore(playerID: fatimah.id, playerName: "Fatimah", totalCorrect: 7))

        _ = service.deletePlayer(id: ahmad.id)

        let scores = service.listScores()
        #expect(scores.count == 1)
        #expect(scores[0].playerID == fatimah.id)
    }

    @Test("Deleting a player with no scores leaves other scores intact")
    func cascadeDeleteNoScoresPlayer() {
        let service = makeService()
        guard case .success(let ahmad) = service.addPlayer(name: "Ahmad"),
              case .success(let fatimah) = service.addPlayer(name: "Fatimah") else {
            Issue.record("Expected success")
            return
        }

        service.saveScore(makeScore(playerID: fatimah.id, playerName: "Fatimah"))

        _ = service.deletePlayer(id: ahmad.id)

        let scores = service.listScores()
        #expect(scores.count == 1)
        #expect(scores[0].playerID == fatimah.id)
    }

    // MARK: - Reset All

    @Test("resetAll clears all players and scores")
    func resetAllClearsEverything() {
        let service = makeService()
        _ = service.addPlayer(name: "Ahmad")
        _ = service.addPlayer(name: "Fatimah")
        let playerID = UUID()
        service.saveScore(makeScore(playerID: playerID))
        service.saveScore(makeScore(playerID: playerID, totalCorrect: 3))

        service.resetAll()

        #expect(service.listPlayers().isEmpty)
        #expect(service.listScores().isEmpty)
    }

    @Test("resetAll on empty storage is a no-op")
    func resetAllEmpty() {
        let service = makeService()
        service.resetAll()

        #expect(service.listPlayers().isEmpty)
        #expect(service.listScores().isEmpty)
    }

    // MARK: - Isolation

    @Test("Tests use isolated UserDefaults")
    func isolation() {
        let service = makeService()
        #expect(service.listPlayers().isEmpty)
        #expect(service.listScores().isEmpty)
    }
}
