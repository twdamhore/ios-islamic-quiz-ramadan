import Foundation

struct ScoreRecord: Identifiable, Codable, Comparable {
    let id: UUID
    let playerID: UUID
    let playerName: String
    let totalCorrect: Int
    let completionTimeSeconds: TimeInterval
    let date: Date

    static func < (lhs: ScoreRecord, rhs: ScoreRecord) -> Bool {
        if lhs.totalCorrect != rhs.totalCorrect {
            return lhs.totalCorrect < rhs.totalCorrect
        }
        return lhs.completionTimeSeconds > rhs.completionTimeSeconds
    }
}
