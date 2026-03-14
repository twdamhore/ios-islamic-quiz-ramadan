import SwiftUI

struct ContentView: View {
    @State private var playerViewModel: PlayerViewModel
    @State private var appState: AppState
    @State private var questions: [Question]?
    @State private var quizViewModel: QuizViewModel?

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
                NavigationStack {
                    HomeView(playerViewModel: playerViewModel, appState: $appState)
                }
            case .playing:
                if let quizViewModel {
                    QuizView(viewModel: quizViewModel)
                }
            case .gameOver:
                if let quizViewModel {
                    GameOverView(
                        totalCorrect: quizViewModel.session.correctCount,
                        completionTime: quizViewModel.displayTime,
                        appState: $appState
                    )
                }
            case .loadError:
                QuestionLoadErrorView()
            }
        }
        .onChange(of: appState) { _, newState in
            if newState == .playing, let questions {
                let vm = QuizViewModel(
                    questions: questions,
                    playerViewModel: playerViewModel
                )
                vm.appState = $appState
                quizViewModel = vm
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
