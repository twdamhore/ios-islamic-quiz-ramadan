import Foundation

struct QuestionLoader {

    private struct RawQuestion: Codable {
        let id: Int
        let level: Int
        let text: String
        let options: [String]
        let correctOptionIndex: Int
    }

    private struct RawQuestionBank: Codable {
        let questions: [RawQuestion]
    }

    static func load(from bundle: Bundle = .main, file: String = "questions.json") -> Result<[Question], QuestionLoadError> {
        let raw: RawQuestionBank
        do {
            raw = try bundle.decode(RawQuestionBank.self, from: file)
        } catch {
            let message = error.localizedDescription
            if let decodingError = error as? DecodingError,
               case .dataCorrupted(let ctx) = decodingError,
               ctx.debugDescription.contains("Missing file") {
                return .failure(.fileNotFound(file))
            }
            return .failure(.decodingFailed(message))
        }

        var seenIDs = Set<Int>()
        for q in raw.questions {
            guard seenIDs.insert(q.id).inserted else {
                return .failure(.duplicateQuestionID(q.id))
            }

            guard q.options.count == 5 else {
                return .failure(.invalidOptionCount(questionID: q.id, count: q.options.count))
            }

            guard q.options.indices.contains(q.correctOptionIndex) else {
                return .failure(.correctOptionIndexOutOfBounds(
                    questionID: q.id, index: q.correctOptionIndex, optionCount: q.options.count
                ))
            }

            var seenOptions = Set<String>()
            for option in q.options {
                guard seenOptions.insert(option).inserted else {
                    return .failure(.duplicateOptionText(questionID: q.id, option: option))
                }
            }
        }

        let questions = raw.questions.map { q in
            Question(id: q.id, level: q.level, text: q.text, options: q.options, correctOptionIndex: q.correctOptionIndex)
        }
        return .success(questions)
    }

    static func loadAll(from bundle: Bundle = .main) -> Result<[Question], QuestionLoadError> {
        var allQuestions: [Question] = []
        for level in 1...10 {
            let file = String(format: "questions-level-%02d.json", level)
            switch load(from: bundle, file: file) {
            case .success(let questions):
                guard questions.count == 10 else {
                    return .failure(.invalidLevelQuestionCount(level: level, count: questions.count, expected: 10))
                }
                allQuestions.append(contentsOf: questions)
            case .failure(let error):
                return .failure(error)
            }
        }

        var seenIDs = Set<Int>()
        for q in allQuestions {
            guard seenIDs.insert(q.id).inserted else {
                return .failure(.duplicateQuestionID(q.id))
            }
        }

        return .success(allQuestions)
    }
}
