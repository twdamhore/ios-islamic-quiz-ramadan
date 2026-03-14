import SwiftUI

struct ProgressBarView: View {
    let current: Int
    let total: Int
    var style: Style = .onLight

    enum Style {
        case onLight
        case onDark
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question \(current) of \(total)")
                .font(AppFonts.caption)
                .foregroundStyle(labelColor)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(trackColor)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.gold)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 12)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progress: question \(current) of \(total)")
        .accessibilityValue("\(current) of \(total)")
    }

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return min(max(CGFloat(current) / CGFloat(total), 0), 1.0)
    }

    private var trackColor: Color {
        switch style {
        case .onLight: AppColors.softTeal.opacity(0.3)
        case .onDark: AppColors.cream.opacity(0.3)
        }
    }

    private var labelColor: Color {
        switch style {
        case .onLight: AppColors.deepPurple
        case .onDark: AppColors.cream
        }
    }
}

#Preview("On Light Background") {
    ProgressBarView(current: 3, total: 10)
        .padding(24)
        .background(AppColors.cream)
}

#Preview("On Dark Background") {
    ProgressBarView(current: 7, total: 10, style: .onDark)
        .padding(24)
        .background(AppColors.midnightBlue)
}
