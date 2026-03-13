import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("QuestionBank JSON loading")
struct QuestionBankTests {

    let bank: QuestionBank

    init() throws {
        bank = try Bundle.main.decode(QuestionBank.self, from: "questions.json")
    }

    @Test("questions.json contains exactly 10 questions")
    func questionCount() {
        #expect(bank.questions.count == 10)
    }

    @Test("Each question has exactly 5 options")
    func optionCount() {
        for question in bank.questions {
            #expect(question.options.count == 5)
        }
    }

    @Test("correctOptionIndex is within bounds for every question")
    func correctIndexInBounds() {
        for question in bank.questions {
            #expect(question.options.indices.contains(question.correctOptionIndex))
        }
    }

    @Test("Question IDs are unique")
    func uniqueIDs() {
        let ids = bank.questions.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("Levels 1 through 10 are each represented exactly once")
    func levelCoverage() {
        let levels = Set(bank.questions.map(\.level))
        #expect(levels == Set(1...10))
    }
}
