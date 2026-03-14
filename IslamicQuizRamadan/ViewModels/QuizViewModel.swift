import Foundation
import Observation

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
}
