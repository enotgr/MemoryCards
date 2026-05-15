//
//  CollectionDetailView.swift
//  MemoryCards
//

import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Bindable var collection: CardCollection
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingNewCard = false
    @State private var isShowingEditCollection = false
    @State private var isShowingTraining = false
    @State private var cardToEdit: Flashcard?

    private var sortedCards: [Flashcard] {
        collection.cards.sorted { $0.createdAt > $1.createdAt }
    }

    private var collectionHeader: some View {
        HStack(spacing: 14) {
            Image(systemName: collection.displayIconName)
                .font(.title2)
                .foregroundStyle(collection.displayColor)
                .frame(width: 48, height: 48)
                .background(collection.displayColor.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(collection.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(cardCountText(for: collection.cards.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                isShowingTraining = true
            } label: {
                Image(systemName: "play.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(collection.displayColor)
                    .clipShape(Circle())
                    .padding(.trailing, 6)
            }
            .buttonStyle(.borderless)
            .disabled(collection.cards.isEmpty)
            .opacity(collection.cards.isEmpty ? 0.45 : 1)
            .accessibilityLabel("Start Training")
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingEditCollection = true
        }
    }

    var body: some View {
        List {
            Section {
                collectionHeader
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))


            Section("Cards") {
                if sortedCards.isEmpty {
                    ContentUnavailableView(
                        "No Cards Yet",
                        systemImage: "text.badge.plus",
                        description: Text("Add a word or phrase and its meaning")
                    )
                } else {
                    ForEach(sortedCards) { card in
                        CardRowView(
                            card: card,
                            onEdit: {
                                cardToEdit = card
                            },
                            onDelete: {
                                deleteCard(card)
                            }
                        )
                    }
                    .onDelete(perform: deleteCards)
                }
            }
        }
        .navigationTitle(collection.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingNewCard = true
                } label: {
                    Label("Add Card", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingNewCard) {
            CardEditorView(mode: .create(collection))
        }
        .sheet(isPresented: $isShowingEditCollection) {
            CollectionEditorView(mode: .edit(collection))
        }
        .sheet(item: $cardToEdit) { card in
            CardEditorView(mode: .edit(card))
        }
        .fullScreenCover(isPresented: $isShowingTraining) {
            TrainingView(collection: collection)
        }
    }

    private func cardCountText(for count: Int) -> String {
        count == 1 ? "1 card" : "\(count) cards"
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                deleteCard(sortedCards[index])
            }
        }
    }

    private func deleteCard(_ card: Flashcard) {
        modelContext.delete(card)
    }
}

private struct CardRowView: View {
    let card: Flashcard
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 6) {
                Text(card.term)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(card.translation)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive, action: onDelete)

            Button("Edit", action: onEdit)
                .tint(.blue)
        }
    }
}
