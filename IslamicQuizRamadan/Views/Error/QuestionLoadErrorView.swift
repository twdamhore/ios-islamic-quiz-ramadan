import SwiftUI

struct QuestionLoadErrorView: View {
    var body: some View {
        ZStack {
            AppColors.cream
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.deepPurple)
                    .accessibilityHidden(true)

                Text("Something went wrong loading questions. Please reinstall the app.")
                    .font(.body)
                    .foregroundStyle(AppColors.deepPurple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    QuestionLoadErrorView()
}
