import SwiftUI
import SwiftData

struct SavedView: View {
    var savedVM: SavedStoriesViewModel
    @Query(sort: \SavedStory.savedAt, order: .reverse) private var savedStories: [SavedStory]
    @Environment(\.modelContext) private var context

    var filtered: [SavedStory] {
        savedVM.filteredStories(savedStories)
    }

    var body: some View {
        NavigationStack {
            Group {
                if savedStories.isEmpty {
                    emptyState
                } else {
                    savedList
                }
            }
            .navigationTitle("Saved")
            .searchable(text: Binding(get: { savedVM.searchText }, set: { savedVM.searchText = $0 }), prompt: "Search saved stories & notes")
        }
    }

    // MARK: - Saved List

    private var savedList: some View {
        List {
            if !filtered.isEmpty {
                ForEach(filtered) { saved in
                    NavigationLink(destination: SavedStoryDetailView(savedStory: saved)) {
                        SavedStoryRowView(savedStory: saved)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            context.delete(saved)
                            try? context.save()
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        } label: {
                            Label("Remove", systemImage: "bookmark.slash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            saved.isRead.toggle()
                            try? context.save()
                        } label: {
                            Label(saved.isRead ? "Unread" : "Read",
                                  systemImage: saved.isRead ? "circle" : "checkmark.circle")
                        }
                        .tint(.blue)
                    }
                }
            } else {
                Text("No results for \"\(savedVM.searchText)\"")
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No Saved Stories")
                .font(.title2.weight(.semibold))
            Text("Tap the bookmark icon on any story to save it here. You can also attach personal notes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Saved Story Row

struct SavedStoryRowView: View {
    let savedStory: SavedStory

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Text(savedStory.title)
                    .font(.system(.body, design: .default).weight(savedStory.isRead ? .regular : .semibold))
                    .foregroundStyle(savedStory.isRead ? .secondary : .primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if !savedStory.isRead {
                    Circle()
                        .fill(.orange)
                        .frame(width: 8, height: 8)
                        .padding(.top, 4)
                }
            }

            if let domain = savedStory.domainName {
                Text(domain)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 12) {
                Label("\(savedStory.score)", systemImage: "arrow.up")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label("\(savedStory.commentCount)", systemImage: "bubble.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("by \(savedStory.author)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(savedStory.savedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !savedStory.note.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.caption2)
                    Text(savedStory.note)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundStyle(.orange.opacity(0.8))
            }
        }
        .padding(.vertical, 6)
    }
}
