import Combine
import Foundation
import Observation
import SwiftUI

enum QuizPhase: Equatable {
    case answering
    case feedback(selectedIndex: Int, isCorrect: Bool)
    case levelComplete(levelScore: Int)
}

@Observable
@MainActor
final class QuizViewModel {

    let allQuestions: [Question]
    let soundService = SoundService()
    private let storage: StorageService
    private let playerViewModel: PlayerViewModel
    var appState: Binding<AppState>?
    private(set) var session = GameSession()
    private(set) var quizPhase: QuizPhase = .answering
    private(set) var currentLevelQuestions: [Question] = []
    private(set) var shuffledOptions: [String] = []
    private(set) var mappedCorrectIndex: Int = 0
    private(set) var displayTime: TimeInterval = 0
    private(set) var isGameComplete = false
    private var autoAdvanceTask: Task<Void, Never>?
    private var feedbackStartDate: Date?
    private var timerCancellable: AnyCancellable?

    var currentQuestion: Question? {
        guard currentLevelQuestions.indices.contains(session.currentQuestionIndex) else {
            return nil
        }
        return currentLevelQuestions[session.currentQuestionIndex]
    }

    init(
        questions: [Question],
        storage: StorageService = StorageService(),
        playerViewModel: PlayerViewModel
    ) {
        self.allQuestions = questions
        self.storage = storage
        self.playerViewModel = playerViewModel
        loadLevelQuestions()
        startTimer()
    }

    // MARK: - Question Shuffling & Option Remapping

    private func loadLevelQuestions() {
        let level = session.currentLevel
        let levelQuestions = allQuestions.filter { $0.level == level }
        currentLevelQuestions = levelQuestions.shuffled()
        session.correctCountAtLevelStart = session.correctCount
        prepareCurrentOptions()
    }

    private func prepareCurrentOptions() {
        guard let question = currentQuestion else { return }
        var indexed = question.options.enumerated().map { ($0.offset, $0.element) }
        indexed.shuffle()
        shuffledOptions = indexed.map(\.1)
        mappedCorrectIndex = indexed.firstIndex(where: { $0.0 == question.correctOptionIndex })!
    }

    // MARK: - Answer Handling

    func selectAnswer(at index: Int) {
        guard !isGameComplete, case .answering = quizPhase else { return }
        let isCorrect = index == mappedCorrectIndex
        if isCorrect {
            session.correctCount += 1
        }
        quizPhase = .feedback(selectedIndex: index, isCorrect: isCorrect)
        feedbackStartDate = Date()
        scheduleAutoAdvance(delay: AppConstants.answerFeedbackDelay)
    }

    func tapNext() {
        cancelAutoAdvance()
        advanceAfterFeedback()
    }

    func scenePhaseChanged(_ phase: ScenePhase) {
        guard !isGameComplete else { return }
        if phase != .active {
            cancelAutoAdvance()
            pauseTimer()
        } else {
            resumeTimer()
            if case .feedback = quizPhase, let start = feedbackStartDate {
                let elapsed = Date().timeIntervalSince(start)
                let remaining = AppConstants.answerFeedbackDelay - elapsed
                if remaining > 0 {
                    scheduleAutoAdvance(delay: remaining)
                } else {
                    advanceAfterFeedback()
                }
            }
        }
    }

    // MARK: - Auto-Advance

    private func scheduleAutoAdvance(delay: TimeInterval) {
        cancelAutoAdvance()
        autoAdvanceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            self?.advanceAfterFeedback()
        }
    }

    private func cancelAutoAdvance() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
    }

    private func advanceAfterFeedback() {
        guard case .feedback = quizPhase else { return }
        feedbackStartDate = nil

        if liveElapsedTime >= AppConstants.maxGameTimeSeconds {
            completeGame(cappedTime: AppConstants.maxGameTimeSeconds)
            return
        }

        session.currentQuestionIndex += 1

        if session.currentQuestionIndex >= AppConstants.questionsPerLevel {
            let levelScore = session.correctCount - session.correctCountAtLevelStart
            pauseTimer()
            quizPhase = .levelComplete(levelScore: levelScore)
        } else {
            quizPhase = .answering
            prepareCurrentOptions()
        }
    }

    // MARK: - Timer

    var liveElapsedTime: TimeInterval {
        guard let resume = session.timerResumeDate else {
            return session.accumulatedPlayTime
        }
        return session.accumulatedPlayTime + Date().timeIntervalSince(resume)
    }

    private func startTimer() {
        session.timerResumeDate = Date()
        createTimerPublisher()
    }

    private func resumeTimer() {
        guard session.timerResumeDate == nil else { return }
        session.timerResumeDate = Date()
        createTimerPublisher()
    }

    private func pauseTimer() {
        guard let resume = session.timerResumeDate else { return }
        session.accumulatedPlayTime += Date().timeIntervalSince(resume)
        session.timerResumeDate = nil
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func createTimerPublisher() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDisplayTime()
            }
        updateDisplayTime()
    }

    private func updateDisplayTime() {
        displayTime = liveElapsedTime
    }

    private func completeGame(cappedTime: TimeInterval? = nil) {
        let finalTime = cappedTime ?? liveElapsedTime
        cancelAutoAdvance()
        pauseTimer()
        displayTime = finalTime
        isGameComplete = true
        saveScore(completionTime: finalTime)
    }

    // MARK: - Level Advance

    func advanceToNextLevel() {
        guard case .levelComplete = quizPhase else { return }
        session.currentLevel += 1

        if session.currentLevel > AppConstants.totalLevels {
            completeGame()
            return
        }

        session.currentQuestionIndex = 0
        loadLevelQuestions()
        resumeTimer()
        quizPhase = .answering
    }

    // MARK: - Quit

    func quit() {
        cancelAutoAdvance()
        pauseTimer()
        appState?.wrappedValue = .home
    }

    // MARK: - Score Saving

    private func saveScore(completionTime: TimeInterval) {
        guard let player = playerViewModel.currentPlayer else { return }
        let score = ScoreRecord(
            playerID: player.id,
            playerName: player.name,
            totalCorrect: session.correctCount,
            completionTimeSeconds: completionTime,
            date: Date()
        )
        storage.saveScore(score)
    }
}
