import Foundation

enum StorageError: Error, Equatable {
    case emptyPlayerName
    case playerNameTooLong(Int)
    case duplicatePlayerName(String)
    case maxPlayersReached(Int)
    case playerNotFound(UUID)
}
