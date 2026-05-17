//
//  ContentView.swift
//  MemoryCards
//
//  Created by Mikhail Krotov on 14.05.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        CollectionListView()
    }
}

#Preview("Light") {
    ContentView()
        .modelContainer(for: [CardCollection.self, Flashcard.self], inMemory: true)
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .modelContainer(for: [CardCollection.self, Flashcard.self], inMemory: true)
        .preferredColorScheme(.dark)
}
