import Foundation

struct Question: Identifiable, Codable {
    let id: Int
    let level: Int
    let text: String
    let options: [String]
    let correctOptionIndex: Int

    init(id: Int, level: Int, text: String, options: [String], correctOptionIndex: Int) {
        self.id = id
        self.level = level
        self.text = text
        self.options = options
        self.correctOptionIndex = correctOptionIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        level = try container.decode(Int.self, forKey: .level)
        text = try container.decode(String.self, forKey: .text)
        options = try container.decode([String].self, forKey: .options)
        correctOptionIndex = try container.decode(Int.self, forKey: .correctOptionIndex)

        guard options.indices.contains(correctOptionIndex) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "correctOptionIndex \(correctOptionIndex) out of bounds for \(options.count) options"
                )
            )
        }
    }
}
