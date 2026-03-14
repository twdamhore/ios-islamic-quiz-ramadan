import SwiftUI

struct StarRatingView: View {
    let filledCount: Int

    private let totalStars = 10

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalStars, id: \.self) { index in
                Image(systemName: index < clampedCount ? "star.fill" : "star")
                    .foregroundStyle(index < clampedCount ? AppColors.gold : .gray)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(clampedCount) out of \(totalStars) stars")
    }

    private var clampedCount: Int {
        min(max(filledCount, 0), totalStars)
    }
}

#Preview("No stars") {
    StarRatingView(filledCount: 0)
        .padding()
}

#Preview("3 stars") {
    StarRatingView(filledCount: 3)
        .padding()
}

#Preview("7 stars") {
    StarRatingView(filledCount: 7)
        .padding()
}

#Preview("Perfect score") {
    StarRatingView(filledCount: 10)
        .padding()
}
