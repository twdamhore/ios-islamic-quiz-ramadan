import Foundation

struct Player: Identifiable, Codable {
    let id: UUID
    let name: String

    init(name: String, id: UUID = UUID()) {
        self.id = id
        self.name = name
    }
}
