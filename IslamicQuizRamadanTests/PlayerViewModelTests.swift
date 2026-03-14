import Foundation
import Testing
@testable import IslamicQuizRamadan

@Suite("PlayerViewModel", .serialized)
@MainActor
struct PlayerViewModelTests {

    private let suiteName = "PlayerViewModelTests"

    private func makeViewModel() -> PlayerViewModel {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = StorageService(defaults: defaults)
        return PlayerViewModel(storage: storage)
    }

    // MARK: - currentPlayer Computed Property

    @Test("currentPlayer is nil when currentPlayerID is nil")
    func currentPlayerNilByDefault() {
        let vm = makeViewModel()
        #expect(vm.currentPlayerID == nil)
        #expect(vm.currentPlayer == nil)
    }

    @Test("currentPlayer returns matching player")
    func currentPlayerReturnsMatch() {
        let vm = makeViewModel()
        guard case .success(let player) = vm.addPlayer(name: "Ahmad") else {
            Issue.record("Expected success")
            return
        }
        vm.currentPlayerID = player.id
        #expect(vm.currentPlayer?.id == player.id)
        #expect(vm.currentPlayer?.name == "Ahmad")
    }

    @Test("currentPlayer returns nil for unknown ID")
    func currentPlayerNilForUnknownID() {
        let vm = makeViewModel()
        _ = vm.addPlayer(name: "Ahmad")
        vm.currentPlayerID = UUID()
        #expect(vm.currentPlayer == nil)
    }

    // MARK: - Duplicate Name Detection

    @Test("Rejects duplicate name (case-insensitive)")
    func duplicateNameCaseInsensitive() {
        let vm = makeViewModel()
        _ = vm.addPlayer(name: "Ahmad")
        let result = vm.addPlayer(name: "ahmad")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .duplicatePlayerName("ahmad"))
    }

    @Test("Rejects duplicate name with different casing")
    func duplicateNameMixedCase() {
        let vm = makeViewModel()
        _ = vm.addPlayer(name: "fatimah")
        let result = vm.addPlayer(name: "FATIMAH")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .duplicatePlayerName("FATIMAH"))
    }

    // MARK: - Max Players Enforcement

    @Test("Rejects adding beyond 12 players")
    func maxPlayersEnforced() {
        let vm = makeViewModel()
        for i in 1...12 {
            guard case .success = vm.addPlayer(name: "Player\(i)") else {
                Issue.record("Expected success for player \(i)")
                return
            }
        }
        let result = vm.addPlayer(name: "Player13")
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .maxPlayersReached(12))
        #expect(vm.players.count == 12)
    }

    // MARK: - Delete Constraints

    @Test("Cannot delete current player")
    func cannotDeleteCurrentPlayer() {
        let vm = makeViewModel()
        guard case .success(let p1) = vm.addPlayer(name: "Ahmad") else {
            Issue.record("Expected success")
            return
        }
        _ = vm.addPlayer(name: "Fatimah")
        vm.currentPlayerID = p1.id

        let result = vm.deletePlayer(id: p1.id)
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .cannotDeleteCurrentPlayer)
        #expect(vm.players.count == 2)
    }

    @Test("Cannot delete sole player")
    func cannotDeleteSolePlayer() {
        let vm = makeViewModel()
        guard case .success(let player) = vm.addPlayer(name: "Ahmad") else {
            Issue.record("Expected success")
            return
        }

        let result = vm.deletePlayer(id: player.id)
        guard case .failure(let error) = result else {
            Issue.record("Expected failure, got \(result)")
            return
        }
        #expect(error == .cannotDeleteSolePlayer)
        #expect(vm.players.count == 1)
    }

    @Test("Can delete non-current player when multiple exist")
    func deleteNonCurrentPlayer() {
        let vm = makeViewModel()
        guard case .success(let p1) = vm.addPlayer(name: "Ahmad") else {
            Issue.record("Expected success")
            return
        }
        guard case .success(let p2) = vm.addPlayer(name: "Fatimah") else {
            Issue.record("Expected success")
            return
        }
        vm.currentPlayerID = p1.id

        let result = vm.deletePlayer(id: p2.id)
        guard case .success = result else {
            Issue.record("Expected success, got \(result)")
            return
        }
        #expect(vm.players.count == 1)
        #expect(vm.players[0].id == p1.id)
    }

    // MARK: - Isolation

    @Test("Tests use isolated UserDefaults")
    func isolation() {
        let vm = makeViewModel()
        #expect(vm.players.isEmpty)
    }
}
