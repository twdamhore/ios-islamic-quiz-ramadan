import SwiftUI

struct TimerView: View {
    let remainingSeconds: TimeInterval

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(AppFonts.title2)
                .foregroundStyle(AppColors.gold)
                .accessibilityHidden(true)

            Text(formattedTime)
                .font(AppFonts.title2)
                .foregroundStyle(AppColors.deepPurple)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time remaining: \(accessibilityTime)")
    }

    private var formattedTime: String {
        let clamped = max(remainingSeconds, 0)
        let minutes = Int(clamped) / 60
        let seconds = Int(clamped) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var accessibilityTime: String {
        let clamped = max(remainingSeconds, 0)
        let minutes = Int(clamped) / 60
        let seconds = Int(clamped) % 60
        if minutes > 0 {
            return "\(minutes) minutes, \(seconds) seconds"
        }
        return "\(seconds) seconds"
    }
}

#Preview("Plenty of time") {
    TimerView(remainingSeconds: 125)
        .padding()
}

#Preview("Low time") {
    TimerView(remainingSeconds: 9)
        .padding()
}

#Preview("Zero") {
    TimerView(remainingSeconds: 0)
        .padding()
}
