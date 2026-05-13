import Foundation
import SwiftData
import Observation
import UIKit

@Observable
class SavedStoriesViewModel {
    var searchText: String = ""

    func isSaved(_ storyId: Int, in saved: [SavedStory]) -> Bool {
        saved.contains { $0.storyId == storyId }
    }

    func savedStory(for id: Int, in saved: [SavedStory]) -> SavedStory? {
        saved.first { $0.storyId == id }
    }

    func toggleSave(item: HNItem, context: ModelContext, saved: [SavedStory]) {
        if let existing = savedStory(for: item.id, in: saved) {
            context.delete(existing)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            let story = SavedStory(from: item)
            context.insert(story)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        try? context.save()
    }

    func updateNote(_ note: String, for story: SavedStory, context: ModelContext) {
        story.note = note
        try? context.save()
    }

    func markRead(_ story: SavedStory, context: ModelContext) {
        story.isRead = true
        try? context.save()
    }

    func filteredStories(_ stories: [SavedStory]) -> [SavedStory] {
        guard !searchText.isEmpty else { return stories }
        let q = searchText.lowercased()
        return stories.filter {
            $0.title.lowercased().contains(q) ||
            $0.author.lowercased().contains(q) ||
            $0.note.lowercased().contains(q) ||
            ($0.domainName?.lowercased().contains(q) ?? false)
        }
    }
}
