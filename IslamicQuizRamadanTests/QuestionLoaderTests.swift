import Foundation
import Testing
@testable import IslamicQuizRamadan

private final class BundleAnchor {}

@Suite("QuestionLoader")
struct QuestionLoaderTests {

    let testBundle = Bundle(for: BundleAnchor.self)

    @Test("Loads valid questions successfully")
    func loadValid() {
        let result = QuestionLoader.load(from: testBundle, file: "valid_questions.json")
        guard case .success(let questions) = result else {
            Issue.record("Expected success, got \(result)")
            return
        }
        #expect(questions.count == 2)
        #expect(questions[0].id == 1)
        #expect(questions[1].id == 2)
    }

    @Test("Fails with invalidOptionCount when a question has wrong number of options")
    func invalidOptionCount() {
        let result = QuestionLoader.load(from: testBundle, file: "invalid_option_count.json")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .invalidOptionCount(questionID: 1, count: 3))
    }

    @Test("Fails with duplicateOptionText when a question has repeated options")
    func duplicateOptions() {
        let result = QuestionLoader.load(from: testBundle, file: "duplicate_options.json")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .duplicateOptionText(questionID: 1, option: "Alpha"))
    }

    @Test("Fails with duplicateQuestionID when two questions share an ID")
    func duplicateIDs() {
        let result = QuestionLoader.load(from: testBundle, file: "duplicate_ids.json")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .duplicateQuestionID(1))
    }

    @Test("Fails with correctOptionIndexOutOfBounds for an invalid index")
    func outOfBoundsIndex() {
        let result = QuestionLoader.load(from: testBundle, file: "invalid_correct_index.json")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .correctOptionIndexOutOfBounds(questionID: 1, index: 7, optionCount: 5))
    }

    @Test("Fails with fileNotFound for a missing file")
    func missingFile() {
        let result = QuestionLoader.load(from: testBundle, file: "nonexistent.json")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .fileNotFound("nonexistent.json"))
    }

    @Test("Fails with questionTextTooLong when text exceeds 120 characters")
    func textTooLong() {
        let result = QuestionLoader.load(from: testBundle, file: "text_too_long.json")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .questionTextTooLong(questionID: 1, length: 160, maxLength: 120))
    }

    @Test("Fails with decodingFailed for corrupt JSON")
    func corruptJSON() {
        let result = QuestionLoader.load(from: testBundle, file: "corrupt.json")
        guard case .failure(.decodingFailed) = result else {
            Issue.record("Expected decodingFailed, got \(result)")
            return
        }
    }

    @Test("loadAll succeeds and returns 100 questions")
    func loadAllSuccess() {
        let result = QuestionLoader.loadAll(from: .main)
        guard case .success(let questions) = result else {
            Issue.record("Expected success, got \(result)")
            return
        }
        #expect(questions.count == 100)
    }

    @Test("Fails with invalidLevelQuestionCount when a level has wrong count")
    func invalidLevelCount() throws {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".bundle")
        try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: tempDir) }

        let fixtureURL = testBundle.url(forResource: "invalid_level_count", withExtension: "json")!
        try fm.copyItem(at: fixtureURL, to: tempDir.appendingPathComponent("questions-level-01.json"))

        let appBundle = Bundle.main
        for level in 2...10 {
            let name = String(format: "questions-level-%02d", level)
            let src = appBundle.url(forResource: name, withExtension: "json")!
            try fm.copyItem(at: src, to: tempDir.appendingPathComponent(name + ".json"))
        }

        let bundle = try #require(Bundle(url: tempDir))
        let result = QuestionLoader.loadAll(from: bundle)
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .invalidLevelQuestionCount(level: 1, count: 2, expected: QuestionLoader.questionsPerLevel))
    }
}
