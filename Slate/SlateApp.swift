//
//  SlateApp.swift
//  Slate
//

import SwiftUI
import SwiftData
import SlateCore

@main
struct SlateApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try SlateModelContainer.make()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
}
