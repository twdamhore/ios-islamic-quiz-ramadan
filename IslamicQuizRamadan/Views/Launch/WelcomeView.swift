import SwiftUI

struct WelcomeView: View {
    @Bindable var playerViewModel: PlayerViewModel
    @Binding var appState: AppState

    @State private var name = ""
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                IslamicHeaderView(title: "Welcome!")

                Text("Enter your name to get started")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.deepPurple)

                VStack(spacing: 12) {
                    TextField("Your name", text: $name)
                        .font(AppFonts.body)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.softTeal, lineWidth: 1)
                        )
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppFonts.caption)
                            .foregroundStyle(.red)
                    }
                }

                Button {
                    createPlayer()
                } label: {
                    Text("Start Playing")
                        .font(AppFonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.deepPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
        }
    }

    private func createPlayer() {
        errorMessage = nil
        let result = playerViewModel.addPlayer(name: name)
        switch result {
        case .success(let player):
            playerViewModel.currentPlayerID = player.id
            appState = .home
        case .failure(let error):
            errorMessage = error.userMessage
        }
    }
}

private extension StorageError {
    var userMessage: String {
        switch self {
        case .emptyPlayerName:
            return "Please enter a name."
        case .playerNameTooLong(let count):
            return "Name is too long (\(count) characters). Maximum is \(AppConstants.maxPlayerNameLength)."
        case .duplicatePlayerName(let name):
            return "A player named \"\(name)\" already exists."
        case .maxPlayersReached(let max):
            return "Maximum of \(max) players reached."
        case .playerNotFound:
            return "Player not found."
        }
    }
}

#Preview {
    @Previewable @State var appState: AppState = .onboarding
    WelcomeView(
        playerViewModel: PlayerViewModel(storage: StorageService(
            defaults: UserDefaults(suiteName: "WelcomeViewPreview")!
        )),
        appState: $appState
    )
}
