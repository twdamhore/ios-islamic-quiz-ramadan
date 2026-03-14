import SwiftUI

struct AnswerButtonView: View {
    enum AnswerState: Equatable {
        case `default`
        case correct
        case wrong
        case disabled
    }

    let text: String
    let answerState: AnswerState
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
                        .foregroundStyle(textColor)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(answerState != .default)
        .accessibilityLabel(accessibilityText)
    }

    private var backgroundColor: Color {
        switch answerState {
        case .default: AppColors.softTeal
        case .correct: Color.green.opacity(0.2)
        case .wrong: Color.red.opacity(0.2)
        case .disabled: AppColors.softTeal.opacity(0.5)
        }
    }

    private var textColor: Color {
        switch answerState {
        case .default, .disabled: AppColors.deepPurple
        case .correct: .green
        case .wrong: .red
        }
    }

    private var icon: String? {
        switch answerState {
        case .correct: "checkmark.circle.fill"
        case .wrong: "xmark.circle.fill"
        default: nil
        }
    }

    private var accessibilityText: String {
        switch answerState {
        case .default: text
        case .correct: "Correct answer: \(text)"
        case .wrong: "Wrong answer: \(text)"
        case .disabled: text
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AnswerButtonView(text: "Default answer", answerState: .default) {}
        AnswerButtonView(text: "Correct answer", answerState: .correct) {}
        AnswerButtonView(text: "Wrong answer", answerState: .wrong) {}
        AnswerButtonView(text: "Disabled answer", answerState: .disabled) {}
    }
    .padding()
}
