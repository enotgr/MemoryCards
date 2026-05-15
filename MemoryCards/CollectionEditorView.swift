//
//  CollectionEditorView.swift
//  MemoryCards
//

import SwiftUI
import SwiftData

struct CollectionEditorView: View {
    enum Mode {
        case create
        case edit(CardCollection)
    }

    let mode: Mode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title: String
    @State private var selectedColorID: String
    @State private var customColor: Color
    @State private var selectedIconID: String

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .create:
            _title = State(initialValue: "")
            _selectedColorID = State(initialValue: CollectionColorOption.defaultID)
            _customColor = State(initialValue: .blue)
            _selectedIconID = State(initialValue: CollectionIconOption.defaultID)
        case .edit(let collection):
            _title = State(initialValue: collection.title)
            _selectedColorID = State(initialValue: collection.colorName ?? CollectionColorOption.defaultID)
            _customColor = State(initialValue: Color(hex: collection.customColorHex ?? "") ?? .blue)
            _selectedIconID = State(initialValue: CollectionIconOption.option(for: collection.iconName).id)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $title)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                }

                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 12)], spacing: 12) {
                        ForEach(CollectionColorOption.all) { option in
                            Button {
                                selectedColorID = option.id
                            } label: {
                                CollectionColorChoiceView(
                                    color: option.color,
                                    isSelected: selectedColorID == option.id
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.name)
                        }

                        ColorPicker(selection: $customColor, supportsOpacity: false) {
                            CollectionPaletteChoiceView(
                                color: customColor,
                                isSelected: selectedColorID == CollectionColorOption.customID
                            )
                        }
                        .labelsHidden()
                        .onChange(of: customColor) { _, _ in
                            selectedColorID = CollectionColorOption.customID
                        }
                        .accessibilityLabel("Custom Color")
                    }
                    .padding(.vertical, 4)
                }

                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 54), spacing: 12)], spacing: 12) {
                        ForEach(CollectionIconOption.all) { option in
                            Button {
                                selectedIconID = option.id
                            } label: {
                                CollectionIconChoiceView(
                                    iconName: option.id,
                                    color: selectedColor,
                                    isSelected: selectedIconID == option.id
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.name)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.screenBackground)
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
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(AppTheme.screenBackground)
    }

    private var navigationTitle: String {
        switch mode {
        case .create:
            return "New collection"
        case .edit:
            return "Edit collection"
        }
    }

    private var saveButtonTitle: String {
        switch mode {
        case .create:
            return "Create"
        case .edit:
            return "Save"
        }
    }

    private var selectedColor: Color {
        selectedColorID == CollectionColorOption.customID ? customColor : CollectionColorOption.option(for: selectedColorID).color
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func save() {
        let customColorHex = selectedColorID == CollectionColorOption.customID ? customColor.hexString() : nil

        switch mode {
        case .create:
            let collection = CardCollection(
                title: trimmedTitle,
                colorName: selectedColorID,
                customColorHex: customColorHex,
                iconName: selectedIconID
            )
            modelContext.insert(collection)
        case .edit(let collection):
            collection.title = trimmedTitle
            collection.colorName = selectedColorID
            collection.customColorHex = customColorHex
            collection.iconName = selectedIconID
        }

        dismiss()
    }
}

private struct CollectionColorChoiceView: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 34, height: 34)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 44, height: 44)
    }
}

private struct CollectionPaletteChoiceView: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 34, height: 34)

            Image(systemName: isSelected ? "checkmark" : "paintpalette.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.24), radius: 2, y: 1)
        }
        .frame(width: 44, height: 44)
    }
}

private struct CollectionIconChoiceView: View {
    let iconName: String
    let color: Color
    let isSelected: Bool

    var body: some View {
        Image(systemName: iconName)
            .font(.title3)
            .foregroundStyle(foregroundColor)
            .frame(width: 46, height: 46)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var foregroundColor: Color {
        isSelected ? .white : color
    }

    private var backgroundColor: Color {
        isSelected ? color : color.opacity(0.14)
    }
}
