import SwiftUI

struct PlayerPickerView: View {
    enum Mode {
        case initial
        case switching
    }

    let mode: Mode
    @Bindable var playerViewModel: PlayerViewModel
    @Binding var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteAlert = false
    @State private var playerToDelete: Player?
    @State private var showAddPlayer = false
    @State private var newPlayerName = ""
    @State private var addPlayerError: String?

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                IslamicHeaderView(title: "Select Player")

                if playerViewModel.players.isEmpty {
                    Text("No players yet.")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.deepPurple)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(playerViewModel.players) { player in
                                playerRow(player)
                            }
                        }
                    }
                }

                if playerViewModel.players.count < AppConstants.maxPlayers {
                    Button {
                        showAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "plus.circle.fill")
                            .font(AppFonts.headline)
                            .foregroundStyle(AppColors.deepPurple)
                    }
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
        }
        .alert("Delete Player", isPresented: $showDeleteAlert, presenting: playerToDelete) { player in
            Button("Delete", role: .destructive) {
                _ = playerViewModel.deletePlayer(id: player.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: { player in
            Text("Are you sure you want to delete \"\(player.name)\"? This will also remove their scores.")
        }
        .alert("Add Player", isPresented: $showAddPlayer) {
            TextField("Name", text: $newPlayerName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
            Button("Add") {
                let result = playerViewModel.addPlayer(name: newPlayerName)
                switch result {
                case .success:
                    newPlayerName = ""
                    addPlayerError = nil
                case .failure(let error):
                    addPlayerError = error.localizedDescription
                }
            }
            Button("Cancel", role: .cancel) {
                newPlayerName = ""
                addPlayerError = nil
            }
        } message: {
            if let addPlayerError {
                Text(addPlayerError)
            } else {
                Text("Enter a name for the new player.")
            }
        }
        .toolbar {
            if mode == .switching {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func playerRow(_ player: Player) -> some View {
        Button {
            playerViewModel.currentPlayerID = player.id
            if mode == .initial {
                appState = .home
            } else {
                dismiss()
            }
        } label: {
            HStack {
                Text(player.name)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.deepPurple)

                Spacer()

                if player.id == playerViewModel.currentPlayerID {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.gold)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        player.id == playerViewModel.currentPlayerID
                            ? AppColors.gold
                            : AppColors.softTeal,
                        lineWidth: player.id == playerViewModel.currentPlayerID ? 2 : 1
                    )
            )
        }
        .contextMenu {
            if canDelete(player) {
                Button("Delete", role: .destructive) {
                    playerToDelete = player
                    showDeleteAlert = true
                }
            }
        }
        .swipeActions(edge: .trailing) {
            if canDelete(player) {
                Button("Delete", role: .destructive) {
                    playerToDelete = player
                    showDeleteAlert = true
                }
            }
        }
    }

    private func canDelete(_ player: Player) -> Bool {
        player.id != playerViewModel.currentPlayerID && playerViewModel.players.count > 1
    }
}

#Preview("Initial Mode") {
    @Previewable @State var appState: AppState = .playerSelection
    let defaults = UserDefaults(suiteName: "PlayerPickerPreview")!
    let storage = StorageService(defaults: defaults)
    let vm = PlayerViewModel(storage: storage)
    PlayerPickerView(mode: .initial, playerViewModel: vm, appState: $appState)
}

#Preview("Switching Mode") {
    @Previewable @State var appState: AppState = .home
    let defaults = UserDefaults(suiteName: "PlayerPickerSwitchPreview")!
    let storage = StorageService(defaults: defaults)
    let vm = PlayerViewModel(storage: storage)
    NavigationStack {
        PlayerPickerView(mode: .switching, playerViewModel: vm, appState: $appState)
    }
}
