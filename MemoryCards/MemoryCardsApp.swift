//
//  MemoryCardsApp.swift
//  MemoryCards
//
//  Created by Михаил Кротов on 14.05.2026.
//

import SwiftUI
import SwiftData

@main
struct MemoryCardsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CardCollection.self,
            Flashcard.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
