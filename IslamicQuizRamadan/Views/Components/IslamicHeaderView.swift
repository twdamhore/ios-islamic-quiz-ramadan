import SwiftUI

struct IslamicHeaderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.deepPurple)
                .accessibilityHidden(true)

            Text(title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.deepPurple)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppColors.cream)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    IslamicHeaderView(title: "Ramadan Quiz")
        .padding()
}
