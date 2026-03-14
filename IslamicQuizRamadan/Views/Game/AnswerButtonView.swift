import SwiftUI

struct AnswerButtonView: View {
    enum State: Equatable {
        case `default`
        case correct
        case wrong
        case disabled
    }

    let text: String
    let state: State
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(AppFonts.body)
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.leading)

                Spacer()

                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(state != .default)
    }

    private var backgroundColor: Color {
        switch state {
        case .default: AppColors.softTeal
        case .correct: Color.green.opacity(0.2)
        case .wrong: Color.red.opacity(0.2)
        case .disabled: AppColors.softTeal.opacity(0.5)
        }
    }

    private var textColor: Color {
        switch state {
        case .default, .disabled: AppColors.deepPurple
        case .correct: .green
        case .wrong: .red
        }
    }

    private var icon: String? {
        switch state {
        case .correct: "checkmark.circle.fill"
        case .wrong: "xmark.circle.fill"
        default: nil
        }
    }

    private var iconColor: Color {
        switch state {
        case .correct: .green
        case .wrong: .red
        default: .clear
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AnswerButtonView(text: "Default answer", state: .default) {}
        AnswerButtonView(text: "Correct answer", state: .correct) {}
        AnswerButtonView(text: "Wrong answer", state: .wrong) {}
        AnswerButtonView(text: "Disabled answer", state: .disabled) {}
    }
    .padding()
}
