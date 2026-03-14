import SwiftUI

struct SettingsView: View {
    @Bindable var playerViewModel: PlayerViewModel
    @Binding var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showFirstConfirm = false
    @State private var showSecondConfirm = false

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Settings")
                    .font(AppFonts.title)
                    .foregroundStyle(AppColors.deepPurple)

                Spacer()

                Button(role: .destructive) {
                    showFirstConfirm = true
                } label: {
                    Text("Reset All Data")
                        .font(AppFonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .alert("Reset everything?", isPresented: $showFirstConfirm) {
            Button("Reset", role: .destructive) {
                showSecondConfirm = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All players and scores will be deleted.")
        }
        .alert("Are you sure?", isPresented: $showSecondConfirm) {
            Button("Delete Everything", role: .destructive) {
                playerViewModel.resetAll()
                dismiss()
                appState = .onboarding
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }
}

#Preview {
    @Previewable @State var appState: AppState = .home
    let defaults = UserDefaults(suiteName: "SettingsPreview")!
    defaults.removePersistentDomain(forName: "SettingsPreview")
    let storage = StorageService(defaults: defaults)
    let pvm = PlayerViewModel(storage: storage)
    return NavigationStack {
        SettingsView(playerViewModel: pvm, appState: $appState)
    }
}
