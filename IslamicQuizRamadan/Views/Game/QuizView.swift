import SwiftUI

struct QuizView: View {
    @Bindable var viewModel: QuizViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showQuitAlert = false

    var body: some View {
        ZStack {
            AppColors.midnightBlue
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                if let question = viewModel.currentQuestion {
                    questionSection(question)
                        .id(question.id)
                        .transition(.opacity)
                    answersSection
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: AppConstants.maxWidth)
            .animation(.easeInOut(duration: 0.2), value: viewModel.session.currentQuestionIndex)

            if case .levelComplete(let levelScore) = viewModel.quizPhase {
                LevelCompleteView(
                    level: viewModel.session.currentLevel,
                    levelScore: levelScore,
                    totalLevels: AppConstants.totalLevels,
                    onContinue: { viewModel.advanceToNextLevel() }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.quizPhase)
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.scenePhaseChanged(newPhase)
        }
        .alert("Quit this game?", isPresented: $showQuitAlert) {
            Button("Quit", role: .destructive) { viewModel.quit() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be lost.")
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Button {
                showQuitAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(AppFonts.title3)
                    .foregroundStyle(AppColors.cream)
            }

            Spacer()

            Text("Level \(viewModel.session.currentLevel) of \(AppConstants.totalLevels)")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.cream)

            Spacer()

            TimerView(remainingSeconds: viewModel.displayTime)
        }
    }

    private func questionSection(_ question: Question) -> some View {
        VStack(spacing: 16) {
            ProgressBarView(
                current: viewModel.session.currentQuestionIndex + 1,
                total: AppConstants.questionsPerLevel,
                style: .onDark
            )

            Text(question.text)
                .font(AppFonts.title3)
                .foregroundStyle(AppColors.cream)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
        }
    }

    private var answersSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.shuffledOptions.enumerated()), id: \.offset) { index, option in
                AnswerButtonView(
                    text: option,
                    answerState: answerState(for: index),
                    action: { viewModel.selectAnswer(at: index) }
                )
            }

            if case .feedback = viewModel.quizPhase {
                Button {
                    viewModel.tapNext()
                } label: {
                    Text("Next")
                        .font(AppFonts.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Helpers

    private func answerState(for index: Int) -> AnswerButtonView.AnswerState {
        switch viewModel.quizPhase {
        case .answering:
            return .default
        case .feedback(let selectedIndex, let isCorrect):
            if index == viewModel.mappedCorrectIndex {
                return .correct
            } else if index == selectedIndex && !isCorrect {
                return .wrong
            }
            return .disabled
        case .levelComplete:
            return .disabled
        }
    }
}

#Preview {
    let questions = (1...10).map {
        Question(id: $0, level: 1, text: "What is the meaning of Q\($0)?",
                 options: ["A", "B", "C", "D", "E"], correctOptionIndex: 0)
    }
    let defaults = UserDefaults(suiteName: "QuizViewPreview")!
    defaults.removePersistentDomain(forName: "QuizViewPreview")
    let storage = StorageService(defaults: defaults)
    let _ = storage.addPlayer(name: "Preview")
    let pvm = PlayerViewModel(storage: storage)
    pvm.currentPlayerID = pvm.players.first?.id
    return QuizView(viewModel: QuizViewModel(
        questions: questions, storage: storage, playerViewModel: pvm
    ))
}
