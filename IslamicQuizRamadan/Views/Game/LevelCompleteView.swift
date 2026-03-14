import SwiftUI

struct LevelCompleteView: View {
    let level: Int
    let levelScore: Int
    let totalLevels: Int
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                IslamicHeaderView(title: "Level \(level) Complete!")

                StarRatingView(filledCount: levelScore)

                Text("\(levelScore) of \(AppConstants.questionsPerLevel) correct")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.deepPurple)

                Button {
                    onContinue()
                } label: {
                    Text(level >= totalLevels ? "See Results" : "Next Level")
                        .font(AppFonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.deepPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(32)
            .background(AppColors.cream)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
        }
    }
}

#Preview {
    LevelCompleteView(level: 3, levelScore: 8, totalLevels: 10, onContinue: {})
}
