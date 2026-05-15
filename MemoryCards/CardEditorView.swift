//
//  CardEditorView.swift
//  MemoryCards
//

import SwiftUI
import SwiftData

struct CardEditorView: View {
    enum Mode {
        case create(CardCollection)
        case edit(Flashcard)
    }

    let mode: Mode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var term: String
    @State private var translation: String

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .create:
            _term = State(initialValue: "")
            _translation = State(initialValue: "")
        case .edit(let card):
            _term = State(initialValue: card.term)
            _translation = State(initialValue: card.translation)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Word or phrase", text: $term, axis: .vertical)
                    .textInputAutocapitalization(.sentences)

                TextField("Meaning", text: $translation, axis: .vertical)
                    .textInputAutocapitalization(.sentences)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(saveButtonTitle) {
                        save()
                    }
                    .disabled(trimmedTerm.isEmpty || trimmedTranslation.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var navigationTitle: String {
        switch mode {
        case .create:
            return "New Card"
        case .edit:
            return "Edit Card"
        }
    }

    private var saveButtonTitle: String {
        switch mode {
        case .create:
            return "Add"
        case .edit:
            return "Save"
        }
    }

    private var trimmedTerm: String {
        term.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedTranslation: String {
        translation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        switch mode {
        case .create(let collection):
            let card = Flashcard(term: trimmedTerm, translation: trimmedTranslation, collection: collection)
            modelContext.insert(card)
            collection.cards.append(card)
        case .edit(let card):
            card.term = trimmedTerm
            card.translation = trimmedTranslation
        }

        dismiss()
    }
}
