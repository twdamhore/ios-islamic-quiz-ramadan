import SwiftUI

struct GameOverView: View {
    let totalCorrect: Int
    let completionTime: TimeInterval
    @Binding var appState: AppState

    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 24) {
                IslamicHeaderView(title: "Game Over!")

                VStack(spacing: 16) {
                    Text("\(totalCorrect) / 100")
                        .font(AppFonts.largeTitle)
                        .foregroundStyle(AppColors.deepPurple)

                    Text("Questions Correct")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.deepPurple)

                    Text(formattedTime)
                        .font(AppFonts.title2)
                        .foregroundStyle(AppColors.gold)
                        .monospacedDigit()

                    Text("Completion Time")
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.deepPurple.opacity(0.7))
                }

                StarRatingView(filledCount: totalCorrect / 10)

                VStack(spacing: 12) {
                    Button {
                        appState = .playing
                    } label: {
                        Text("Play Again")
                            .font(AppFonts.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.deepPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        appState = .home
                    } label: {
                        Text("Home")
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
        }
    }

    private var formattedTime: String {
        let minutes = Int(completionTime) / 60
        let seconds = Int(completionTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    @Previewable @State var appState: AppState = .gameOver
    GameOverView(totalCorrect: 85, completionTime: 1234, appState: $appState)
}
