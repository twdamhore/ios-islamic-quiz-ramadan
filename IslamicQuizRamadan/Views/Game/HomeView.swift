import SwiftUI

enum ActiveSheet: Identifiable, Hashable {
    case leaderboard
    case switchPlayer
    case settings

    var id: Self { self }
}

struct HomeView: View {
    @Bindable var playerViewModel: PlayerViewModel
    @Binding var appState: AppState
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                IslamicHeaderView(title: "Assalamu Alaikum,\n\(playerViewModel.currentPlayer?.name ?? "Player")!")

                VStack(spacing: 16) {
                    Button {
                        appState = .playing
                    } label: {
                        Text("Play")
                            .font(AppFonts.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.deepPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        activeSheet = .leaderboard
                    } label: {
                        Text("Leaderboard")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.deepPurple)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.softTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        activeSheet = .switchPlayer
                    } label: {
                        Text("Switch Player")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.deepPurple)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.softTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .settings
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(AppColors.deepPurple)
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .leaderboard:
                NavigationStack {
                    Text("Leaderboard (coming soon)")
                }
            case .switchPlayer:
                NavigationStack {
                    PlayerPickerView(
                        mode: .switching,
                        playerViewModel: playerViewModel,
                        appState: $appState
                    )
                }
            case .settings:
                NavigationStack {
                    SettingsView(
                        playerViewModel: playerViewModel,
                        appState: $appState
                    )
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var appState: AppState = .home
    let defaults = UserDefaults(suiteName: "HomeViewPreview")!
    defaults.removePersistentDomain(forName: "HomeViewPreview")
    let storage = StorageService(defaults: defaults)
    let _ = storage.addPlayer(name: "Ahmad")
    let pvm = PlayerViewModel(storage: storage)
    pvm.currentPlayerID = pvm.players.first?.id
    return NavigationStack {
        HomeView(playerViewModel: pvm, appState: $appState)
    }
}
