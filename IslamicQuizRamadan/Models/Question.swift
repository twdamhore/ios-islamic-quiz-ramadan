import Foundation

struct Question: Identifiable, Codable {
    let id: Int
    let level: Int
    let text: String
    let options: [String]
    let correctOptionIndex: Int
}
