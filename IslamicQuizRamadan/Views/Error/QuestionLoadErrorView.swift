import SwiftUI

struct QuestionLoadErrorView: View {
    private let creamBackground = Color(red: 253 / 255, green: 246 / 255, blue: 236 / 255)
    private let darkGreen = Color(red: 0.0, green: 0.3, blue: 0.15)

    var body: some View {
        ZStack {
            creamBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 56))
                    .foregroundStyle(darkGreen)
                    .accessibilityHidden(true)

                Text("Something went wrong loading questions. Please reinstall the app.")
                    .font(.body)
                    .foregroundStyle(darkGreen)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

#Preview {
    QuestionLoadErrorView()
}
