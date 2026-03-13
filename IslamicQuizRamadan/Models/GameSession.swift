import Foundation

struct GameSession {
    var currentLevel: Int = 1
    var currentQuestionIndex: Int = 0
    var correctCount: Int = 0
    var correctCountAtLevelStart: Int = 0
    var accumulatedPlayTime: TimeInterval = 0
    /// Set to `.now` when the timer starts or resumes; `nil` while paused or before first start.
    var timerResumeDate: Date?
}
