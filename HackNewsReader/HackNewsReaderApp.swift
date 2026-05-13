//
//  HackNewsReaderApp.swift
//  HackNewsReader
//
//  Created by REAL  on 13/05/26.
//

import SwiftUI
import SwiftData

@main
struct HackNewsReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedStory.self)
    }
}
