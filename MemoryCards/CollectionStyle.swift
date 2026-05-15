//
//  CollectionStyle.swift
//  MemoryCards
//

import SwiftUI

struct CollectionColorOption: Identifiable, Hashable {
    let id: String
    let name: String
    let color: Color

    static let defaultID = "blue"
    static let customID = "custom"

    static let all: [CollectionColorOption] = [
        CollectionColorOption(id: "blue", name: "Blue", color: .blue),
        CollectionColorOption(id: "green", name: "Green", color: .green),
        CollectionColorOption(id: "yellow", name: "Yellow", color: .yellow),
        CollectionColorOption(id: "orange", name: "Orange", color: .orange),
        CollectionColorOption(id: "red", name: "Red", color: .red),
        CollectionColorOption(id: "purple", name: "Purple", color: .purple),
        CollectionColorOption(id: "pink", name: "Pink", color: .pink),
        CollectionColorOption(id: "indigo", name: "Indigo", color: .indigo),
        CollectionColorOption(id: "mint", name: "Mint", color: .mint),
        CollectionColorOption(id: "brown", name: "Brown", color: .brown),
        CollectionColorOption(id: "gray", name: "Gray", color: .gray)
    ]

    static func option(for id: String?) -> CollectionColorOption {
        all.first { $0.id == id } ?? all[0]
    }
}

struct CollectionIconOption: Identifiable, Hashable {
    let id: String
    let name: String

    static let defaultID = "rectangle.stack.fill"

    static let all: [CollectionIconOption] = [
        CollectionIconOption(id: "rectangle.stack.fill", name: "Cards"),
        CollectionIconOption(id: "book.closed.fill", name: "Book"),
        CollectionIconOption(id: "character.book.closed.fill", name: "Language"),
        CollectionIconOption(id: "graduationcap.fill", name: "Study"),
        CollectionIconOption(id: "globe", name: "World"),
        CollectionIconOption(id: "star.fill", name: "Favorites"),
        CollectionIconOption(id: "lightbulb.fill", name: "Ideas"),
        CollectionIconOption(id: "brain.head.profile", name: "Memory"),
        CollectionIconOption(id: "pencil.and.list.clipboard", name: "Notes"),
        CollectionIconOption(id: "sparkles", name: "Practice")
    ]

    static func option(for id: String?) -> CollectionIconOption {
        all.first { $0.id == id } ?? all[0]
    }
}

extension CardCollection {
    var displayColor: Color {
        if colorName == CollectionColorOption.customID, let customColorHex {
            return Color(hex: customColorHex) ?? CollectionColorOption.option(for: nil).color
        }

        return CollectionColorOption.option(for: colorName).color
    }

    var displayIconName: String {
        CollectionIconOption.option(for: iconName).id
    }
}

extension Color {
    init?(hex: String) {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanedHex.hasPrefix("#") {
            cleanedHex.removeFirst()
        }

        guard cleanedHex.count == 6, let value = Int(cleanedHex, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self = Color(red: red, green: green, blue: blue)
    }

    func hexString() -> String? {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
        #else
        return nil
        #endif
    }
}
