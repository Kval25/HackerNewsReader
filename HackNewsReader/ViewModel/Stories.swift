import Foundation
import SwiftUI
import Observation

@Observable
class StoriesViewModel {
    var stories: [HNItem] = []
    var isLoading = false
    var isLoadingMore = false
    var error: String?
    var selectedFeed: FeedType = .top
    var readStoryIds: Set<Int> = []

    private var allIds: [Int] = []
    private var loadedCount = 0
    private let pageSize = 30

    func loadFeed(refresh: Bool = false) async {
        guard !isLoading else { return }
        if refresh { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }

        isLoading = true
        error = nil

        do {
            allIds = try await HNAPIService.shared.fetchStoryIds(feed: selectedFeed)
            loadedCount = 0
            stories = []
            await loadNextPage()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func loadNextPage() async {
        guard !isLoadingMore, loadedCount < allIds.count else { return }
        isLoadingMore = true

        let start = loadedCount
        let end = min(start + pageSize, allIds.count)
        let idsToLoad = Array(allIds[start..<end])

        do {
            let newItems = try await HNAPIService.shared.fetchItems(ids: idsToLoad)
            stories.append(contentsOf: newItems)
            loadedCount = end
        } catch {
            self.error = error.localizedDescription
        }

        isLoadingMore = false
    }

    func markAsRead(_ id: Int) {
        readStoryIds.insert(id)
    }

    func changeFeed(to feed: FeedType) async {
        selectedFeed = feed
        await loadFeed(refresh: true)
    }

    var hasMore: Bool { loadedCount < allIds.count }
}
