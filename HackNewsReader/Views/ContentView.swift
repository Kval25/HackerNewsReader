//
//  ContentView.swift
//  HackNewsReader
//
//  Created by REAL  on 13/05/26.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var savedStories: [SavedStory]
    @State private var storiesVM = StoriesViewModel()
    @State private var savedVM = SavedStoriesViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            StoriesView(vm: storiesVM, savedVM: savedVM)
                .tabItem {
                    Label("Feed", systemImage: "newspaper.fill")
                }
                .tag(0)

            SavedView(savedVM: savedVM)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .badge(savedStories.filter { !$0.isRead }.count > 0 ? savedStories.filter { !$0.isRead }.count : 0)
                .tag(1)
        }
        .task {
            await storiesVM.loadFeed()
        }
    }
}

#Preview {
    ContentView()
}
