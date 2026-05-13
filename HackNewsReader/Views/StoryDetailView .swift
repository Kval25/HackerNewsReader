import SwiftUI
import SafariServices
import SwiftData

struct StoryDetailView: View {
    let story: HNItem
    @State private var vm: StoryDetailViewModel
    @Environment(\.modelContext) private var context
    @Query private var savedStories: [SavedStory]
    @State private var showSafari = false
    @State private var showNoteEditor = false

    init(story: HNItem) {
        self.story = story
        _vm = State(wrappedValue: StoryDetailViewModel(story: story))
    }

    var savedStory: SavedStory? {
        savedStories.first { $0.storyId == story.id }
    }

    var isSaved: Bool { savedStory != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                storyHeader
                Divider()
                commentsSection
            }
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isSaved {
                    Button { showNoteEditor = true } label: {
                        Image(systemName: savedStory?.note.isEmpty == false ? "note.text" : "note.text.badge.plus")
                    }
                }
                Button { toggleSave() } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isSaved ? .orange : .primary)
                }
                if story.articleURL != nil {
                    Button { showSafari = true } label: {
                        Image(systemName: "safari")
                    }
                }
            }
        }
        .task {
            await vm.loadComments()
        }
        .fullScreenCover(isPresented: $showSafari) {
            if let url = story.articleURL {
                SafariView(url: url).ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            if let saved = savedStory {
                NoteEditorView(savedStory: saved)
            }
        }
    }

    // MARK: - Story Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(story.title ?? "Untitled")
                .font(.title2.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)

            if let domain = story.domainName {
                Button { showSafari = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "link").font(.caption)
                        Text(domain).font(.subheadline)
                    }
                    .foregroundStyle(.orange)
                }
            }

            HStack(spacing: 16) {
                Label("\(story.score ?? 0) points", systemImage: "arrow.up.circle.fill")
                    .font(.subheadline).foregroundStyle(.orange)
                Label(story.by ?? "", systemImage: "person.fill")
                    .font(.subheadline).foregroundStyle(.secondary)
                Label(story.formattedTime, systemImage: "clock")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            if story.articleURL != nil {
                Button { showSafari = true } label: {
                    Text("Read Article →")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }

            if let text = story.strippedText, !text.isEmpty {
                Text(text).font(.body).foregroundStyle(.primary).padding(.top, 4)
            }

            if let note = savedStory?.note, !note.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text").foregroundStyle(.orange).font(.caption).padding(.top, 2)
                    Text(note).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(12)
                .background(.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Label("\(story.commentCount) comments", systemImage: "bubble.right")
                .font(.subheadline.weight(.semibold)).foregroundStyle(.secondary).padding(.top, 4)
        }
        .padding(16)
    }

    // MARK: - Comments

    private var commentsSection: some View {
        Group {
            if vm.isLoadingComments {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading comments…").font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity).padding(40)
            } else if vm.comments.isEmpty && story.childIds.isEmpty {
                Text("No comments yet.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity).padding(40)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(vm.comments) { node in
                        CommentView(node: node)
                    }
                }
            }
        }
    }

    // MARK: - Save / Unsave

    private func toggleSave() {
        if let existing = savedStory {
            context.delete(existing)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            let s = SavedStory(from: story)
            context.insert(s)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        try? context.save()
    }
}

// MARK: - Safari View

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
