import Foundation

enum QuestionLoadError: Error, Equatable {
    case fileNotFound(String)
    case decodingFailed(String)
    case invalidOptionCount(questionID: Int, count: Int)
    case duplicateOptionText(questionID: Int, option: String)
    case duplicateQuestionID(Int)
    case correctOptionIndexOutOfBounds(questionID: Int, index: Int, optionCount: Int)
    case questionTextTooLong(questionID: Int, length: Int, maxLength: Int)
    case invalidLevelQuestionCount(level: Int, count: Int, expected: Int)
}
