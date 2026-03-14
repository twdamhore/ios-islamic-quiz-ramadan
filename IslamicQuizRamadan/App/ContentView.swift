import SwiftUI

struct ContentView: View {
    @State private var playerViewModel: PlayerViewModel
    @State private var appState: AppState
    @State private var questions: [Question]?

    init() {
        let storage = StorageService()
        let playerVM = PlayerViewModel(storage: storage)
        _playerViewModel = State(initialValue: playerVM)

        switch QuestionLoader.loadAll() {
        case .success(let loadedQuestions):
            _questions = State(initialValue: loadedQuestions)
            if playerVM.players.isEmpty {
                _appState = State(initialValue: .onboarding)
            } else {
                _appState = State(initialValue: .playerSelection)
            }
        case .failure:
            _questions = State(initialValue: nil)
            _appState = State(initialValue: .loadError)
        }
    }

    var body: some View {
        Group {
            switch appState {
            case .onboarding:
                WelcomeView(playerViewModel: playerViewModel, appState: $appState)
            case .playerSelection:
                PlayerPickerView(
                    mode: .initial,
                    playerViewModel: playerViewModel,
                    appState: $appState
                )
            case .home:
                Text("Home – \(playerViewModel.currentPlayer?.name ?? "No Player")")
            case .playing:
                Text("Playing")
            case .gameOver:
                Text("Game Over")
            case .loadError:
                QuestionLoadErrorView()
            }
        }
        .onChange(of: playerViewModel.players.isEmpty) { _, isEmpty in
            if isEmpty && appState != .loadError {
                appState = .onboarding
            }
        }
    }
}

#Preview {
    ContentView()
}
