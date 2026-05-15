//
//  AppTheme.swift
//  MemoryCards
//

import SwiftUI

enum AppTheme {
    static let screenBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let inputBackground = Color(.tertiarySystemGroupedBackground)
    static let border = Color(.separator).opacity(0.28)

    static func elevatedShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .black.opacity(0.32) : .black.opacity(0.08)
    }
}
