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

    func loadLevelQuestions() {
        let level = session.currentLevel
        let levelQuestions = allQuestions.filter { $0.level == level }
        currentLevelQuestions = levelQuestions.shuffled()
        session.correctCountAtLevelStart = session.correctCount
        prepareCurrentOptions()
    }

    func prepareCurrentOptions() {
        guard let question = currentQuestion else { return }
        let correctAnswer = question.options[question.correctOptionIndex]
        var options = question.options
        options.shuffle()
        shuffledOptions = options
        mappedCorrectIndex = options.firstIndex(of: correctAnswer) ?? 0
    }
}
