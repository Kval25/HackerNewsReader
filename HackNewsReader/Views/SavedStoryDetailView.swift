import SwiftUI
import SwiftData
import SafariServices

struct SavedStoryDetailView: View {
    @Bindable var savedStory: SavedStory
    @Environment(\.modelContext) private var context
    @State private var showNoteEditor = false
    @State private var showSafari = false

    var articleURL: URL? {
        guard let url = savedStory.url else { return nil }
        return URL(string: url)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(savedStory.title)
                    .font(.title2.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)

                // Domain
                if let domain = savedStory.domainName {
                    Text(domain)
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }

                // Meta
                HStack(spacing: 16) {
                    Label("\(savedStory.score)", systemImage: "arrow.up.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    Label(savedStory.author, systemImage: "person.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Note section
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Personal Note", systemImage: "note.text")
                            .font(.headline)
                        Spacer()
                        Button("Edit") {
                            showNoteEditor = true
                        }
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    }

                    if savedStory.note.isEmpty {
                        Button {
                            showNoteEditor = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.dashed")
                                Text("Add a note…")
                            }
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(savedStory.note)
                            .font(.body)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Divider()

                // Saved date
                HStack {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(.orange)
                    Text("Saved \(savedStory.savedAt.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Read status
                Toggle(isOn: $savedStory.isRead) {
                    Label("Marked as Read", systemImage: "checkmark.circle")
                }
                .onChange(of: savedStory.isRead) { _, _ in
                    try? context.save()
                }

                // Open article button
                if articleURL != nil {
                    Button {
                        showSafari = true
                    } label: {
                        HStack {
                            Image(systemName: "safari.fill")
                            Text("Open Article")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Saved Story")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !savedStory.isRead {
                savedStory.isRead = true
                try? context.save()
            }
        }
        .sheet(isPresented: $showNoteEditor) {
            NoteEditorView(savedStory: savedStory)
        }
        .fullScreenCover(isPresented: $showSafari) {
            if let url = articleURL {
                SafariView(url: url).ignoresSafeArea()
            }
        }
    }
}
