import Foundation

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) throws -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Missing file: \(file)")
            )
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
