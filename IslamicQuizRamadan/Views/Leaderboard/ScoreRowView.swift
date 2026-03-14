import SwiftUI

struct ScoreRowView: View {
    let rank: Int
    let score: ScoreRecord

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.gold)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(score.playerName)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.deepPurple)

                Text(relativeDate)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.deepPurple.opacity(0.6))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score.totalCorrect)/100")
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.deepPurple)

                Text(formattedTime)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.deepPurple.opacity(0.6))
                    .monospacedDigit()
            }
        }
        .padding(12)
        .background(AppColors.cream)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var formattedTime: String {
        let minutes = Int(score.completionTimeSeconds) / 60
        let seconds = Int(score.completionTimeSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: score.date, relativeTo: Date())
    }
}

#Preview {
    ScoreRowView(
        rank: 1,
        score: ScoreRecord(
            playerID: UUID(),
            playerName: "Ahmad",
            totalCorrect: 95,
            completionTimeSeconds: 1234
        )
    )
    .padding()
}
