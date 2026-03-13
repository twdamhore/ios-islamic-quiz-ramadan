import Foundation

struct ScoreRecord: Identifiable, Codable, Comparable {
    let id: UUID
    let playerID: UUID
    let playerName: String
    let totalCorrect: Int
    let completionTimeSeconds: TimeInterval
    let date: Date

    init(
        playerID: UUID,
        playerName: String,
        totalCorrect: Int,
        completionTimeSeconds: TimeInterval,
        id: UUID = UUID(),
        date: Date = .now
    ) {
        self.id = id
        self.playerID = playerID
        self.playerName = playerName
        self.totalCorrect = totalCorrect
        self.completionTimeSeconds = completionTimeSeconds
        self.date = date
    }

    static func < (lhs: ScoreRecord, rhs: ScoreRecord) -> Bool {
        if lhs.totalCorrect != rhs.totalCorrect {
            return lhs.totalCorrect < rhs.totalCorrect
        }
        return lhs.completionTimeSeconds > rhs.completionTimeSeconds
    }
}
