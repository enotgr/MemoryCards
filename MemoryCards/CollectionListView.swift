//
//  CollectionListView.swift
//  MemoryCards
//
//  Created by Mikhail Krotov on 14.05.2026.
//

import SwiftUI
import SwiftData

struct CollectionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CardCollection.createdAt, order: .reverse) private var collections: [CardCollection]
    @State private var isShowingNewCollection = false
    @State private var quickTrainingCollection: CardCollection?
    @State private var selectedCollection: CardCollection?
    @State private var isShowingCollectionDetail = false

    var body: some View {
        NavigationStack {
            Group {
                if collections.isEmpty {
                    emptyState
                } else {
                    collectionList
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingNewCollection = true
                    } label: {
                        Label("Add Collection", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingCollectionDetail) {
                if let selectedCollection {
                    CollectionDetailView(collection: selectedCollection)
                }
            }
            .sheet(isPresented: $isShowingNewCollection) {
                CollectionEditorView(mode: .create)
            }
            .fullScreenCover(item: $quickTrainingCollection) { collection in
                TrainingView(collection: collection)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No collections",
            systemImage: "rectangle.stack.badge.plus",
            description: Text("Create your first collection and add cards to remember")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 32)
    }

    private var collectionList: some View {
        List {
            ForEach(collections) { collection in
                CollectionRowView(
                    collection: collection,
                    onOpen: {
                        selectedCollection = collection
                        isShowingCollectionDetail = true
                    },
                    onStartTraining: {
                        quickTrainingCollection = collection
                    },
                    onDelete: {
                        deleteCollection(collection)
                    }
                )
            }
            .onDelete(perform: deleteCollections)
        }
    }

    private func deleteCollections(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                deleteCollection(collections[index])
            }
        }
    }

    private func deleteCollection(_ collection: CardCollection) {
        modelContext.delete(collection)
    }
}

private struct CollectionRowView: View {
    let collection: CardCollection
    let onOpen: () -> Void
    let onStartTraining: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: collection.displayIconName)
                .font(.headline)
                .foregroundStyle(collection.displayColor)
                .frame(width: 36, height: 36)
                .background(collection.displayColor.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(collection.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(cardCountText(for: collection.cards.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)

            Button(action: onStartTraining) {
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
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive, action: onDelete)
        }
    }

    private func cardCountText(for count: Int) -> String {
        count == 1 ? "1 card" : "\(count) cards"
    }
}
