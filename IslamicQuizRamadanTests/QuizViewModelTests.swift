import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("QuizViewModel", .serialized)
@MainActor
struct QuizViewModelTests {

    private let suiteName = "QuizViewModelTests"

    private func makeTestQuestions(levels: Int = 1, perLevel: Int = 10, correctIndex: Int? = nil) -> [Question] {
        var questions: [Question] = []
        for level in 1...levels {
            for i in 0..<perLevel {
                let id = (level - 1) * perLevel + i + 1
                questions.append(Question(
                    id: id,
                    level: level,
                    text: "Q\(id)",
                    options: ["A", "B", "C", "D", "E"],
                    correctOptionIndex: correctIndex ?? (id % 5)
                ))
            }
        }
        return questions
    }

    private func makeViewModel(
        questions: [Question]? = nil,
        levels: Int = 1,
        perLevel: Int = 10,
        correctIndex: Int? = nil,
        playerName: String = "TestPlayer"
    ) -> (QuizViewModel, StorageService) {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        _ = storage.addPlayer(name: playerName)
        let playerVM = PlayerViewModel(storage: storage)
        playerVM.currentPlayerID = playerVM.players.first!.id
        let vm = QuizViewModel(
            questions: questions ?? makeTestQuestions(levels: levels, perLevel: perLevel, correctIndex: correctIndex),
            storage: storage,
            playerViewModel: playerVM
        )
        return (vm, storage)
    }

    // MARK: - Scoring

    @Test("Correct answer increments correctCount")
    func correctAnswerIncrements() {
        let (vm, _) = makeViewModel()
        let correctIdx = vm.mappedCorrectIndex
        vm.selectAnswer(at: correctIdx)
        #expect(vm.session.correctCount == 1)
    }

    @Test("Incorrect answer does not increment correctCount")
    func incorrectAnswerNoIncrement() {
        let (vm, _) = makeViewModel()
        let wrongIdx = (vm.mappedCorrectIndex + 1) % 5
        vm.selectAnswer(at: wrongIdx)
        #expect(vm.session.correctCount == 0)
    }

    // MARK: - Randomization

    @Test("Questions are shuffled per level")
    func questionsShuffledPerLevel() {
        let questions = makeTestQuestions(levels: 1, perLevel: 10)
        let originalOrder = questions.filter { $0.level == 1 }.map(\.id)
        var differentOrderSeen = false
        for _ in 0..<20 {
            let (vm, _) = makeViewModel(questions: questions)
            let shuffledOrder = vm.currentLevelQuestions.map(\.id)
            if shuffledOrder != originalOrder {
                differentOrderSeen = true
                break
            }
        }
        #expect(differentOrderSeen)
    }

    @Test("Options are shuffled with correct index remapped")
    func optionsShuffledWithRemap() {
        let (vm, _) = makeViewModel()
        guard let question = vm.currentQuestion else {
            Issue.record("No current question")
            return
        }
        let correctAnswer = question.options[question.correctOptionIndex]
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == correctAnswer)
    }

    // MARK: - Index Remapping

    @Test("Correct answer at index 0 is properly tracked")
    func correctAtIndex0() {
        let (vm, _) = makeViewModel(correctIndex: 0)
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == "A")
    }

    @Test("Correct answer at index 4 is properly tracked")
    func correctAtIndex4() {
        let (vm, _) = makeViewModel(correctIndex: 4)
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == "E")
    }

    @Test("Correct answer at middle index is properly tracked")
    func correctAtMiddleIndex() {
        let (vm, _) = makeViewModel(correctIndex: 2)
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == "C")
    }

    // MARK: - Game Flow

    @Test("Double-tap is prevented by phase guard")
    func doubleTapPrevented() {
        let (vm, _) = makeViewModel()
        let correctIdx = vm.mappedCorrectIndex
        vm.selectAnswer(at: correctIdx)
        vm.selectAnswer(at: correctIdx)
        #expect(vm.session.correctCount == 1)
    }

    @Test("Level complete after 10 questions")
    func levelCompleteAfter10() {
        let (vm, _) = makeViewModel()
        for _ in 0..<10 {
            vm.selectAnswer(at: 0)
            vm.tapNext()
        }
        guard case .levelComplete = vm.quizPhase else {
            Issue.record("Expected .levelComplete, got \(vm.quizPhase)")
            return
        }
    }

    // MARK: - Timer Pause Accumulation

    @Test("Timer accumulates correctly across pause/resume")
    func timerPauseAccumulation() {
        let (vm, _) = makeViewModel()
        #expect(vm.session.timerResumeDate != nil)

        // Pause timer — accumulatedPlayTime should increase from 0
        vm.scenePhaseChanged(.background)
        #expect(vm.session.timerResumeDate == nil)
        let accum1 = vm.session.accumulatedPlayTime
        #expect(accum1 >= 0)

        // Resume timer
        vm.scenePhaseChanged(.active)
        #expect(vm.session.timerResumeDate != nil)

        // Pause again — accumulatedPlayTime should be >= previous
        vm.scenePhaseChanged(.background)
        #expect(vm.session.accumulatedPlayTime >= accum1)
    }

    // MARK: - Save on Completion

    @Test("Score saved on game completion")
    func scoreSavedOnCompletion() {
        let (vm, storage) = makeViewModel(levels: 10, perLevel: 10, playerName: "Scorer")

        for level in 1...10 {
            for _ in 0..<10 {
                vm.selectAnswer(at: vm.mappedCorrectIndex)
                vm.tapNext()
            }
            if level < 10 {
                vm.advanceToNextLevel()
            }
        }
        vm.advanceToNextLevel()

        #expect(vm.isGameComplete)
        let scores = storage.listScores()
        #expect(scores.count == 1)
        #expect(scores[0].playerName == "Scorer")
        #expect(scores[0].totalCorrect == 100)
    }
}
