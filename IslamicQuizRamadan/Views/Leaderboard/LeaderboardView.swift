import SwiftUI

struct LeaderboardView: View {
    @State private var viewModel: LeaderboardViewModel
    @State private var showMyScores = false
    @Environment(\.dismiss) private var dismiss

    init(storage: StorageService = StorageService(), currentPlayerID: UUID? = nil) {
        _viewModel = State(initialValue: LeaderboardViewModel(
            storage: storage, currentPlayerID: currentPlayerID
        ))
    }

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                IslamicHeaderView(title: "Leaderboard")

                Picker("View", selection: $showMyScores) {
                    Text("All Players").tag(false)
                    Text("My Scores").tag(true)
                }
                .pickerStyle(.segmented)

                let scores = showMyScores ? viewModel.myScores : viewModel.allScores

                if scores.isEmpty {
                    Spacer()
                    Text(emptyMessage)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.deepPurple.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
                                ScoreRowView(rank: index + 1, score: score)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private var emptyMessage: String {
        showMyScores
            ? "You haven't completed a game yet. Give it a try!"
            : "No scores yet. Play a game to get on the leaderboard!"
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
