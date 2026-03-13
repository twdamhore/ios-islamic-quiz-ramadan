import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("StorageService – Score Persistence", .serialized)
struct StorageServiceScoreTests {

    private let suiteName = "StorageServiceScoreTests"

    private func makeService() -> StorageService {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return StorageService(defaults: defaults)
    }

    private func makeScore(
        totalCorrect: Int = 7,
        completionTimeSeconds: TimeInterval = 120,
        playerID: UUID = UUID(),
        playerName: String = "Ahmad"
    ) -> ScoreRecord {
        ScoreRecord(
            playerID: playerID,
            playerName: playerName,
            totalCorrect: totalCorrect,
            completionTimeSeconds: completionTimeSeconds
        )
    }

    // MARK: - Save & List

    @Test("Save a score and list returns it")
    func saveAndList() {
        let service = makeService()
        let score = makeScore()
        service.saveScore(score)

        let scores = service.listScores()
        #expect(scores.count == 1)
        #expect(scores[0].id == score.id)
        #expect(scores[0].totalCorrect == 7)
    }

    @Test("Save multiple scores and list returns all")
    func saveMultiple() {
        let service = makeService()
        service.saveScore(makeScore(totalCorrect: 5))
        service.saveScore(makeScore(totalCorrect: 8))
        service.saveScore(makeScore(totalCorrect: 3))

        let scores = service.listScores()
        #expect(scores.count == 3)
    }

    @Test("Scores are returned sorted by rank descending")
    func sortedByRank() {
        let service = makeService()
        service.saveScore(makeScore(totalCorrect: 3, completionTimeSeconds: 100))
        service.saveScore(makeScore(totalCorrect: 8, completionTimeSeconds: 200))
        service.saveScore(makeScore(totalCorrect: 8, completionTimeSeconds: 90))
        service.saveScore(makeScore(totalCorrect: 5, completionTimeSeconds: 60))

        let scores = service.listScores()
        #expect(scores[0].totalCorrect == 8)
        #expect(scores[0].completionTimeSeconds == 90)
        #expect(scores[1].totalCorrect == 8)
        #expect(scores[1].completionTimeSeconds == 200)
        #expect(scores[2].totalCorrect == 5)
        #expect(scores[3].totalCorrect == 3)
    }

    // MARK: - Pruning

    @Test("Pruning keeps top 50 scores when exceeding limit")
    func pruningAtLimit() {
        let service = makeService()

        for i in 1...50 {
            service.saveScore(makeScore(totalCorrect: i))
        }
        #expect(service.listScores().count == 50)

        service.saveScore(makeScore(totalCorrect: 25))

        let scores = service.listScores()
        #expect(scores.count == 50)
    }

    @Test("Pruning removes lowest-ranked score")
    func pruningRemovesLowest() {
        let service = makeService()

        for i in 1...50 {
            service.saveScore(makeScore(totalCorrect: i))
        }

        service.saveScore(makeScore(totalCorrect: 51))

        let scores = service.listScores()
        #expect(scores.count == 50)
        #expect(scores.last!.totalCorrect == 2)
        #expect(scores.first!.totalCorrect == 51)
    }

    @Test("Pruning uses time as tiebreaker")
    func pruningTimeTiebreaker() {
        let service = makeService()

        for i in 1...49 {
            service.saveScore(makeScore(totalCorrect: 10, completionTimeSeconds: 100))
        }
        let slowScore = makeScore(totalCorrect: 10, completionTimeSeconds: 300)
        service.saveScore(slowScore)

        #expect(service.listScores().count == 50)

        let fastScore = makeScore(totalCorrect: 10, completionTimeSeconds: 50)
        service.saveScore(fastScore)

        let scores = service.listScores()
        #expect(scores.count == 50)
        #expect(!scores.contains(where: { $0.id == slowScore.id }))
        #expect(scores.contains(where: { $0.id == fastScore.id }))
    }

    // MARK: - Isolation

    @Test("Tests use isolated UserDefaults")
    func isolation() {
        let service = makeService()
        #expect(service.listScores().isEmpty)
    }
}
