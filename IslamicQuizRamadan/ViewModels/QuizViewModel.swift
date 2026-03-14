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
    private(set) var session = GameSession()
    private(set) var quizPhase: QuizPhase = .answering
    private(set) var currentLevelQuestions: [Question] = []
    private(set) var shuffledOptions: [String] = []
    private(set) var mappedCorrectIndex: Int = 0
    private var autoAdvanceTask: Task<Void, Never>?
    private var feedbackStartDate: Date?

    var currentQuestion: Question? {
        guard currentLevelQuestions.indices.contains(session.currentQuestionIndex) else {
            return nil
        }
        return currentLevelQuestions[session.currentQuestionIndex]
    }

    init(questions: [Question]) {
        self.allQuestions = questions
        loadLevelQuestions()
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
        guard case .answering = quizPhase else { return }
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
        if phase != .active {
            cancelAutoAdvance()
        } else if case .feedback = quizPhase, let start = feedbackStartDate {
            let elapsed = Date().timeIntervalSince(start)
            let remaining = AppConstants.answerFeedbackDelay - elapsed
            if remaining > 0 {
                scheduleAutoAdvance(delay: remaining)
            } else {
                advanceAfterFeedback()
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
        session.currentQuestionIndex += 1

        if session.currentQuestionIndex >= AppConstants.questionsPerLevel {
            let levelScore = session.correctCount - session.correctCountAtLevelStart
            quizPhase = .levelComplete(levelScore: levelScore)
        } else {
            quizPhase = .answering
            prepareCurrentOptions()
        }
    }
}
