import SwiftUI

struct StoryRowView: View {
    let story: HNItem
    let rank: Int
    let isRead: Bool
    let isSaved: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story)) {
            HStack(alignment: .top, spacing: 12) {
                // Rank number
                Text("\(rank)")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .trailing)
                    .padding(.top, 3)

                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(story.title ?? "Untitled")
                        .font(.system(.body, design: .default).weight(isRead ? .regular : .semibold))
                        .foregroundStyle(isRead ? .secondary : .primary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Domain
                    if let domain = story.domainName {
                        Text(domain)
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                    }
                    
                    // Meta row
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up")
                            Text("\(story.score ?? 0)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        
                        HStack(spacing: 3) {
                            Image(systemName: "bubble.right")
                            Text("\(story.commentCount)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        
                        Text(story.by ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(story.formattedTime)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                // Save button
                Button {
                    onSave()
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(isSaved ? .orange : .secondary)
                        .font(.system(size: 18))
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(.vertical, 8)
        }
        .listRowSeparator(.visible)
    }
}
