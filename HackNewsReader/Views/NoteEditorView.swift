import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Bindable var savedStory: SavedStory
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @FocusState private var isFocused: Bool
    @State private var draftNote: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Story context
                VStack(alignment: .leading, spacing: 4) {
                    Text(savedStory.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Text("by \(savedStory.author)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGroupedBackground))

                Divider()

                // Text editor
                TextEditor(text: $draftNote)
                    .focused($isFocused)
                    .font(.body)
                    .padding(16)
                    .overlay(alignment: .topLeading) {
                        if draftNote.isEmpty {
                            Text("Write your thoughts, key points, or why you saved this…")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                                .padding(20)
                                .allowsHitTesting(false)
                        }
                    }

                Spacer()
            }
            .navigationTitle("Personal Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savedStory.note = draftNote
                        try? context.save()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                }
            }
        }
        .onAppear {
            draftNote = savedStory.note
            isFocused = true
        }
    }
}
