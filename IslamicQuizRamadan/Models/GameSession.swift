import Foundation

struct GameSession {
    var currentLevel: Int
    var currentQuestionIndex: Int
    var correctCount: Int
    var correctCountAtLevelStart: Int
    var accumulatedPlayTime: TimeInterval
    var timerResumeDate: Date
}
