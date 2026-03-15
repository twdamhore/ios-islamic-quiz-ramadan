import SwiftUI

struct StarRatingView: View {
    let filledCount: Int
    var animated: Bool = false

    private let totalStars = 10
    @State private var visibleStars = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalStars, id: \.self) { index in
                let isFilled = animated ? index < visibleStars : index < clampedCount
                Image(systemName: isFilled ? "star.fill" : "star")
                    .foregroundStyle(isFilled ? AppColors.gold : .gray)
                    .scaleEffect(isFilled ? 1.0 : 0.8)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6)
                            .delay(Double(index) * 0.08),
                        value: visibleStars
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(clampedCount) out of \(totalStars) stars")
        .onAppear {
            if animated {
                visibleStars = clampedCount
            }
        }
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
