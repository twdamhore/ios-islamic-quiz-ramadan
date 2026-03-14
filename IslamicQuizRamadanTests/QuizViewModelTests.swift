import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("QuizViewModel", .serialized)
@MainActor
struct QuizViewModelTests {

    private let suiteName = "QuizViewModelTests"

    private func makeTestQuestions(levels: Int = 1, perLevel: Int = 10) -> [Question] {
        var questions: [Question] = []
        for level in 1...levels {
            for i in 0..<perLevel {
                let id = (level - 1) * perLevel + i + 1
                questions.append(Question(
                    id: id,
                    level: level,
                    text: "Q\(id)",
                    options: ["A", "B", "C", "D", "E"],
                    correctOptionIndex: id % 5
                ))
            }
        }
        return questions
    }

    private func makeViewModel(
        levels: Int = 1,
        perLevel: Int = 10
    ) -> QuizViewModel {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        _ = storage.addPlayer(name: "TestPlayer")
        let playerVM = PlayerViewModel(storage: storage)
        playerVM.currentPlayerID = playerVM.players.first!.id
        return QuizViewModel(
            questions: makeTestQuestions(levels: levels, perLevel: perLevel),
            storage: storage,
            playerViewModel: playerVM
        )
    }

    // MARK: - Scoring

    @Test("Correct answer increments correctCount")
    func correctAnswerIncrements() {
        let vm = makeViewModel()
        let correctIdx = vm.mappedCorrectIndex
        vm.selectAnswer(at: correctIdx)
        #expect(vm.session.correctCount == 1)
    }

    @Test("Incorrect answer does not increment correctCount")
    func incorrectAnswerNoIncrement() {
        let vm = makeViewModel()
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
            let defaults = UserDefaults(suiteName: suiteName)!
            defaults.removePersistentDomain(forName: suiteName)
            let storage = StorageService(defaults: defaults)
            _ = storage.addPlayer(name: "Test")
            let pvm = PlayerViewModel(storage: storage)
            pvm.currentPlayerID = pvm.players.first!.id
            let vm = QuizViewModel(questions: questions, storage: storage, playerViewModel: pvm)
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
        let vm = makeViewModel()
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
        let q = Question(id: 1, level: 1, text: "Q", options: ["A", "B", "C", "D", "E"], correctOptionIndex: 0)
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        _ = storage.addPlayer(name: "Test")
        let pvm = PlayerViewModel(storage: storage)
        pvm.currentPlayerID = pvm.players.first!.id
        let vm = QuizViewModel(
            questions: Array(repeating: q, count: 10).enumerated().map {
                Question(id: $0.offset + 1, level: 1, text: "Q\($0.offset)", options: $0.element.options, correctOptionIndex: 0)
            },
            storage: storage, playerViewModel: pvm
        )
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == "A")
    }

    @Test("Correct answer at index 4 is properly tracked")
    func correctAtIndex4() {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        _ = storage.addPlayer(name: "Test")
        let pvm = PlayerViewModel(storage: storage)
        pvm.currentPlayerID = pvm.players.first!.id
        let vm = QuizViewModel(
            questions: (1...10).map {
                Question(id: $0, level: 1, text: "Q\($0)", options: ["A", "B", "C", "D", "E"], correctOptionIndex: 4)
            },
            storage: storage, playerViewModel: pvm
        )
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == "E")
    }

    @Test("Correct answer at middle index is properly tracked")
    func correctAtMiddleIndex() {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        _ = storage.addPlayer(name: "Test")
        let pvm = PlayerViewModel(storage: storage)
        pvm.currentPlayerID = pvm.players.first!.id
        let vm = QuizViewModel(
            questions: (1...10).map {
                Question(id: $0, level: 1, text: "Q\($0)", options: ["A", "B", "C", "D", "E"], correctOptionIndex: 2)
            },
            storage: storage, playerViewModel: pvm
        )
        #expect(vm.shuffledOptions[vm.mappedCorrectIndex] == "C")
    }

    // MARK: - Game Flow

    @Test("Double-tap is prevented by phase guard")
    func doubleTapPrevented() {
        let vm = makeViewModel()
        let correctIdx = vm.mappedCorrectIndex
        vm.selectAnswer(at: correctIdx)
        vm.selectAnswer(at: correctIdx)
        #expect(vm.session.correctCount == 1)
    }

    @Test("Level complete after 10 questions")
    func levelCompleteAfter10() {
        let vm = makeViewModel()
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
        let vm = makeViewModel()
        #expect(vm.session.timerResumeDate != nil)
        vm.scenePhaseChanged(.background)
        #expect(vm.session.timerResumeDate == nil)
        let accum1 = vm.session.accumulatedPlayTime
        #expect(accum1 >= 0)
        vm.scenePhaseChanged(.active)
        #expect(vm.session.timerResumeDate != nil)
    }

    // MARK: - Save on Completion

    @Test("Score saved on game completion")
    func scoreSavedOnCompletion() {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        _ = storage.addPlayer(name: "Scorer")
        let pvm = PlayerViewModel(storage: storage)
        pvm.currentPlayerID = pvm.players.first!.id

        let vm = QuizViewModel(
            questions: makeTestQuestions(levels: 10, perLevel: 10),
            storage: storage,
            playerViewModel: pvm
        )

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

    // MARK: - Isolation

    @Test("Tests use isolated UserDefaults")
    func isolation() {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        #expect(storage.listScores().isEmpty)
    }
}
