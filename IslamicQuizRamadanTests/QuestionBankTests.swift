import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("QuestionBank JSON loading")
struct QuestionBankTests {

    let questions: [Question]

    init() throws {
        let result = QuestionLoader.loadAll()
        switch result {
        case .success(let q):
            questions = q
        case .failure(let error):
            throw error
        }
    }

    @Test("Question files contain exactly 100 questions")
    func questionCount() {
        #expect(questions.count == 100)
    }

    @Test("Each question has exactly 5 options")
    func optionCount() {
        for question in questions {
            #expect(question.options.count == 5)
        }
    }

    @Test("correctOptionIndex is within bounds for every question")
    func correctIndexInBounds() {
        for question in questions {
            #expect(question.options.indices.contains(question.correctOptionIndex))
        }
    }

    @Test("Question IDs are unique")
    func uniqueIDs() {
        let ids = questions.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("All question texts are at most 120 characters")
    func questionTextLength() {
        for question in questions {
            #expect(question.text.count <= 120, "Question \(question.id) text is \(question.text.count) characters")
        }
    }

    @Test("Levels 1 through 10 each have exactly 10 questions")
    func levelCoverage() {
        let levels = Set(questions.map(\.level))
        #expect(levels == Set(1...10))
        for level in 1...10 {
            let count = questions.filter { $0.level == level }.count
            #expect(count == 10, "Level \(level) should have 10 questions but has \(count)")
        }
    }
}
