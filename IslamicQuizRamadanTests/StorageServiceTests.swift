import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("StorageService – Player CRUD", .serialized)
struct StorageServiceTests {

    private let suiteName = "StorageServiceTests"

    private func makeService() -> StorageService {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return StorageService(defaults: defaults)
    }

    // MARK: - Add & List

    @Test("Add a player and list returns it")
    func addAndList() {
        let service = makeService()
        let result = service.addPlayer(name: "Ahmad")
        guard case .success(let player) = result else {
            Issue.record("Expected success, got \(result)")
            return
        }
        #expect(player.name == "Ahmad")

        let players = service.listPlayers()
        #expect(players.count == 1)
        #expect(players[0].id == player.id)
        #expect(players[0].name == "Ahmad")
    }

    @Test("Add multiple players and list returns all")
    func addMultiple() {
        let service = makeService()
        _ = service.addPlayer(name: "Ahmad")
        _ = service.addPlayer(name: "Fatimah")
        _ = service.addPlayer(name: "Omar")

        let players = service.listPlayers()
        #expect(players.count == 3)
    }

    // MARK: - Delete

    @Test("Delete removes the player")
    func deletePlayer() {
        let service = makeService()
        guard case .success(let player) = service.addPlayer(name: "Ahmad") else {
            Issue.record("Expected success")
            return
        }
        _ = service.addPlayer(name: "Fatimah")

        let deleteResult = service.deletePlayer(id: player.id)
        guard case .success = deleteResult else {
            Issue.record("Expected success, got \(deleteResult)")
            return
        }

        let players = service.listPlayers()
        #expect(players.count == 1)
        #expect(players[0].name == "Fatimah")
    }

    @Test("Delete unknown player returns playerNotFound")
    func deleteUnknown() {
        let service = makeService()
        let fakeID = UUID()
        let result = service.deletePlayer(id: fakeID)
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .playerNotFound(fakeID))
    }

    // MARK: - Duplicate Name Validation

    @Test("Rejects duplicate name (case-insensitive)")
    func duplicateNameCaseInsensitive() {
        let service = makeService()
        _ = service.addPlayer(name: "Ahmad")

        let result = service.addPlayer(name: "ahmad")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .duplicatePlayerName("ahmad"))
    }

    @Test("Rejects duplicate name with different casing")
    func duplicateNameMixedCase() {
        let service = makeService()
        _ = service.addPlayer(name: "fatimah")

        let result = service.addPlayer(name: "FATIMAH")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .duplicatePlayerName("FATIMAH"))
    }

    // MARK: - Name Trimming & Length Validation

    @Test("Trims whitespace from player name")
    func trimWhitespace() {
        let service = makeService()
        guard case .success(let player) = service.addPlayer(name: "  Ahmad  ") else {
            Issue.record("Expected success")
            return
        }
        #expect(player.name == "Ahmad")
    }

    @Test("Rejects empty name")
    func emptyName() {
        let service = makeService()
        let result = service.addPlayer(name: "")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .emptyPlayerName)
    }

    @Test("Rejects whitespace-only name")
    func whitespaceOnlyName() {
        let service = makeService()
        let result = service.addPlayer(name: "   ")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .emptyPlayerName)
    }

    @Test("Rejects name longer than 20 characters")
    func nameTooLong() {
        let service = makeService()
        let longName = String(repeating: "A", count: 21)
        let result = service.addPlayer(name: longName)
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .playerNameTooLong(21))
    }

    @Test("Accepts name with exactly 20 characters")
    func nameExactly20() {
        let service = makeService()
        let name = String(repeating: "A", count: 20)
        let result = service.addPlayer(name: name)
        guard case .success(let player) = result else {
            Issue.record("Expected success, got \(result)")
            return
        }
        #expect(player.name == name)
    }

    // MARK: - Max Players

    @Test("Rejects adding beyond 12 players")
    func maxPlayersEnforced() {
        let service = makeService()
        for i in 1...12 {
            let result = service.addPlayer(name: "Player\(i)")
            guard case .success = result else {
                Issue.record("Expected success for player \(i), got \(result)")
                return
            }
        }

        let result = service.addPlayer(name: "Player13")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .maxPlayersReached(12))
        #expect(service.listPlayers().count == 12)
    }

    // MARK: - Isolation

    @Test("Tests use isolated UserDefaults")
    func isolation() {
        let service = makeService()
        #expect(service.listPlayers().isEmpty)
    }
}
