//
//  Models.swift
//  MemoryCards
//
//  Created by Михаил Кротов on 14.05.2026.
//

import Foundation
import SwiftData

@Model
final class CardCollection {
    var title: String
    var colorName: String?
    var customColorHex: String?
    var iconName: String?
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Flashcard.collection) var cards: [Flashcard]

    init(
        title: String,
        colorName: String? = nil,
        customColorHex: String? = nil,
        iconName: String? = nil,
        createdAt: Date = Date(),
        cards: [Flashcard] = []
    ) {
        self.title = title
        self.colorName = colorName
        self.customColorHex = customColorHex
        self.iconName = iconName
        self.createdAt = createdAt
        self.cards = cards
    }
}

@Model
final class Flashcard {
    var term: String
    var translation: String
    var createdAt: Date
    var collection: CardCollection?

    init(term: String, translation: String, createdAt: Date = Date(), collection: CardCollection? = nil) {
        self.term = term
        self.translation = translation
        self.createdAt = createdAt
        self.collection = collection
    }
}
