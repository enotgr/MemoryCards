//
//  ContentView.swift
//  MemoryCards
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
