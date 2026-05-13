import SwiftUI

struct CommentView: View {
    var node: CommentNode
    private let depthColors: [Color] = [.orange, .blue, .purple, .green, .pink, .teal]

    var body: some View {
        if !node.isDeleted {
            VStack(alignment: .leading, spacing: 0) {
                commentBubble
                if !node.isCollapsed {
                    ForEach(node.children) { child in
                        CommentView(node: child)
                    }
                }
            }
        } else {
            EmptyView()
        }
    }

    private var depthColor: Color {
        depthColors[node.depth % depthColors.count]
    }

    private var commentBubble: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    node.isCollapsed.toggle()
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                HStack(alignment: .top, spacing: 0) {
                    // Depth indicator bar
                    if node.depth > 0 {
                        Rectangle()
                            .fill(depthColor.opacity(0.5))
                            .frame(width: 2)
                            .padding(.leading, CGFloat(node.depth) * 12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        // Header
                        HStack(spacing: 8) {
                            Text(node.item?.by ?? "[deleted]")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(depthColor)

                            Text(node.item?.formattedTime ?? "")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)

                            Spacer()

                            if !node.children.isEmpty {
                                HStack(spacing: 2) {
                                    Image(systemName: node.isCollapsed ? "chevron.right" : "chevron.down")
                                        .font(.caption2)
                                    if node.isCollapsed {
                                        Text("\(node.children.count)")
                                            .font(.caption2)
                                    }
                                }
                                .foregroundStyle(.tertiary)
                            }
                        }

                        // Comment text
                        if !node.isCollapsed, let text = node.item?.strippedText, !text.isEmpty {
                            Text(text)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.leading, node.depth > 0 ? 8 : 0)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                }
            }
            .buttonStyle(.plain)
            .background(
                Color(.systemBackground)
                    .overlay(
                        Rectangle()
                            .fill(Color(.systemGroupedBackground))
                            .opacity(Double(node.depth) * 0.05)
                    )
            )

            Divider()
                .padding(.leading, CGFloat(max(node.depth, 1)) * 12 + 16)
        }
    }
}
