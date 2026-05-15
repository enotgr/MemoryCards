//
//  TrainingView.swift
//  MemoryCards
//

import SwiftUI

struct TrainingView: View {
    let collection: CardCollection
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var cards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var answer = ""
    @State private var score = 0
    @State private var isAnswerChecked = false
    @State private var isCorrect = false
    @Namespace private var resultCardNamespace
    @FocusState private var isAnswerFocused: Bool

    private var currentCard: Flashcard? {
        cards.indices.contains(currentIndex) ? cards[currentIndex] : nil
    }

    private var isFinished: Bool {
        currentIndex >= cards.count
    }

    private var completedCardCount: Int {
        min(currentIndex + (isAnswerChecked ? 1 : 0), cards.count)
    }

    private var isLastCard: Bool {
        currentIndex == cards.count - 1
    }

    private var scorePercentage: Int {
        guard !cards.isEmpty else { return 0 }
        return Int((Double(score) / Double(cards.count) * 100).rounded())
    }

    private var resultColor: Color {
        switch scorePercentage {
        case 100:
            return .blue
        case 80...99:
            return .green
        case 50...79:
            return .orange
        default:
            return .red
        }
    }

    private var resultIconName: String {
        switch scorePercentage {
        case 100:
            return "crown.fill"
        case 80...99:
            return "checkmark.seal.fill"
        case 50...79:
            return "exclamationmark.circle.fill"
        default:
            return "xmark.circle.fill"
        }
    }

    private var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(completedCardCount) / Double(cards.count)
    }

    private var progressPercentage: Int {
        Int((progress * 100).rounded())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.screenBackground
                    .ignoresSafeArea()

                if isFinished {
                    finishView
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    ScrollView {
                        VStack(spacing: 22) {
                            if let card = currentCard {
                                trainingContent(for: card)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .safeAreaInset(edge: .bottom) {
                        if currentCard != nil {
                            answerPanel
                        }
                    }
                }
            }
            .navigationTitle("Training")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
            .animation(.spring(response: 0.48, dampingFraction: 0.88), value: isFinished)
            .onAppear(perform: startSession)
        }
    }

    private func trainingContent(for card: Flashcard) -> some View {
        VStack(spacing: 18) {
            progressHeader

            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text(card.term)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity)
                }

                if isAnswerChecked {
                    Divider()

                    Text(card.translation)
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, minHeight: 280)
            .matchedGeometryEffect(id: "resultCard", in: resultCardNamespace)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppTheme.border, lineWidth: 1)
            }
            .shadow(color: AppTheme.elevatedShadow(for: colorScheme), radius: 18, y: 8)
            .animation(.snappy, value: isAnswerChecked)

            if isAnswerChecked {
                ResultBadge(isCorrect: isCorrect)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var answerPanel: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "keyboard")
                    .foregroundStyle(.secondary)

                TextField("Enter meaning", text: $answer)
                    .disabled(isAnswerChecked)
                    .focused($isAnswerFocused)
                    .submitLabel(.done)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .onSubmit(submitAnswer)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(isAnswerFocused ? Color.accentColor : AppTheme.border, lineWidth: 1)
            }

            Button {
                isAnswerChecked ? showNextCard() : checkAnswer()
            } label: {
                Label(primaryButtonTitle, systemImage: primaryButtonIconName)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 22))
            .disabled(!isAnswerChecked && trimmedAnswer.isEmpty)
            .controlSize(.large)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private var primaryButtonTitle: String {
        if isAnswerChecked && isLastCard {
            return "Finish"
        }

        return isAnswerChecked ? "Next Card" : "Check Answer"
    }

    private var primaryButtonIconName: String {
        if isAnswerChecked && isLastCard {
            return "flag.checkered"
        }

        return isAnswerChecked ? "arrow.right" : "checkmark"
    }

    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.title)
                        .font(.headline)

                    Text("\(completedCardCount) of \(cards.count) completed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(progressPercentage)%")
                        .font(.title3.weight(.bold))

                    Text("Done")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: progress)
                .tint(.accentColor)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AppTheme.border, lineWidth: 1)
        }
    }

    private var finishView: some View {
        VStack(spacing: 22) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(resultColor.opacity(0.14))
                        .frame(width: 88, height: 88)

                    Image(systemName: resultIconName)
                        .font(.system(size: 44))
                        .foregroundStyle(resultColor)
                }

                Text("Training completed")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("You scored \(scorePercentage)%")
                    .font(.headline)
                    .foregroundStyle(resultColor)
            }
            .padding(28)
            .frame(maxWidth: .infinity)
            .matchedGeometryEffect(id: "resultCard", in: resultCardNamespace)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppTheme.border, lineWidth: 1)
            }
            .shadow(color: AppTheme.elevatedShadow(for: colorScheme), radius: 18, y: 8)

            VStack(spacing: 12) {
                Button {
                    startSession()
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 18))
                .tint(resultColor)
                .controlSize(.large)

                Button {
                    dismiss()
                } label: {
                    Text("Back to Collection")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 18))
                .tint(.secondary)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: 460)
    }

    private var trimmedAnswer: String {
        answer.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func startSession() {
        cards = collection.cards.shuffled()
        currentIndex = 0
        score = 0
        answer = ""
        isAnswerChecked = false
        isCorrect = false
        isAnswerFocused = true
    }

    private func submitAnswer() {
        guard !trimmedAnswer.isEmpty else {
            isAnswerFocused = false
            return
        }

        checkAnswer()
    }

    private func checkAnswer() {
        guard let card = currentCard, !isAnswerChecked else { return }

        isCorrect = normalized(trimmedAnswer) == normalized(card.translation)
        if isCorrect {
            score += 1
        }
        isAnswerChecked = true
        isAnswerFocused = false
    }

    private func showNextCard() {
        currentIndex += 1
        answer = ""
        isAnswerChecked = false
        isCorrect = false
        isAnswerFocused = true
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}

private struct ResultBadge: View {
    let isCorrect: Bool

    var body: some View {
        Label(isCorrect ? "Correct" : "Correct meaning", systemImage: isCorrect ? "checkmark.circle.fill" : "info.circle.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isCorrect ? .green : .orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background((isCorrect ? Color.green : Color.orange).opacity(0.12))
            .clipShape(Capsule())
    }
}
