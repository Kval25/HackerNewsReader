import SwiftUI
import SwiftData

struct StoriesView: View {
    var vm: StoriesViewModel
    var savedVM: SavedStoriesViewModel
    @Query private var savedStories: [SavedStory]
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.stories.isEmpty {
                    loadingView
                } else if let error = vm.error, vm.stories.isEmpty {
                    errorView(error)
                } else {
                    storyList
                }
            }
            .navigationTitle(vm.selectedFeed.label)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    feedPicker
                }
            }
            .refreshable {
                await vm.loadFeed(refresh: true)
            }
        }
    }

    // MARK: - Story List

    private var storyList: some View {
        List {
            ForEach(Array(vm.stories.enumerated()), id: \.element.id) { index, story in
                StoryRowView(
                    story: story,
                    rank: index + 1,
                    isRead: vm.readStoryIds.contains(story.id),
                    isSaved: savedVM.isSaved(story.id, in: savedStories),
                    onSave: {
                        savedVM.toggleSave(item: story, context: context, saved: savedStories)
                    }
                )
                .onAppear {
                    if story.id == vm.stories.last?.id && vm.hasMore {
                        Task { await vm.loadNextPage() }
                    }
                }
            }

            if vm.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView().padding()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Feed Picker

    private var feedPicker: some View {
        Menu {
            ForEach(FeedType.allCases) { feed in
                Button {
                    Task { await vm.changeFeed(to: feed) }
                } label: {
                    Label(feed.label, systemImage: feed.systemImage)
                }
            }
        } label: {
            Image(systemName: vm.selectedFeed.systemImage)
                .font(.title3)
        }
    }

    // MARK: - Loading / Error

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("Loading \(vm.selectedFeed.label) stories…")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("Couldn't load stories")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await vm.loadFeed() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
