import Foundation

enum AppState: Equatable, Hashable {
    case onboarding
    case playerSelection
    case home
    case playing
    case gameOver
    case loadError
}
