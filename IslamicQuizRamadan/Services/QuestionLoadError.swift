import Foundation

enum QuestionLoadError: Error, Equatable {
    case fileNotFound(String)
    case decodingFailed(String)
    case invalidOptionCount(questionID: Int, count: Int)
    case duplicateOptionText(questionID: Int, option: String)
    case duplicateQuestionID(Int)
    case correctOptionIndexOutOfBounds(questionID: Int, index: Int, optionCount: Int)
}
