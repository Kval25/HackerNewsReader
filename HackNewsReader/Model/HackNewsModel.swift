import Foundation
import SwiftData
import Observation

// MARK: - HackerNews API Models

struct HNItem: Codable, Identifiable,Sendable {
    let id: Int
    let type: String?
    let by: String?
    let time: TimeInterval?
    let text: String?
    let dead: Bool?
    let parent: Int?
    let poll: Int?
    let kids: [Int]?
    let url: String?
    let score: Int?
    let title: String?
    let parts: [Int]?
    let descendants: Int?
    let deleted: Bool?

    var isDeleted: Bool { deleted == true }
    var isDead: Bool { dead == true }

    var formattedTime: String {
        guard let time else { return "" }
        let date = Date(timeIntervalSince1970: time)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var commentCount: Int { descendants ?? 0 }
    var childIds: [Int] { kids ?? [] }

    var articleURL: URL? {
        guard let url else { return nil }
        return URL(string: url)
    }

    var strippedText: String? {
        guard let text else { return nil }
        return text
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#x2F;", with: "/")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var domainName: String? {
        guard let url = articleURL,
              let host = url.host else { return nil }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}

// MARK: - Feed Type

enum FeedType: String, CaseIterable, Identifiable {
    case top = "topstories"
    case new = "newstories"
    case best = "beststories"
    case ask = "askstories"
    case show = "showstories"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .top: return "Top"
        case .new: return "New"
        case .best: return "Best"
        case .ask: return "Ask"
        case .show: return "Show"
        }
    }

    var systemImage: String {
        switch self {
        case .top: return "flame.fill"
        case .new: return "clock.fill"
        case .best: return "star.fill"
        case .ask: return "questionmark.bubble.fill"
        case .show: return "eye.fill"
        }
    }
}

// MARK: - Comment Node (for threaded view)

@Observable
final class CommentNode: Identifiable, @unchecked Sendable {
    let id: Int
    let item: HNItem?
    var children: [CommentNode]
    var isCollapsed: Bool = false
    let depth: Int

    init(id: Int, item: HNItem?, children: [CommentNode] = [], depth: Int = 0) {
        self.id = id
        self.item = item
        self.children = children
        self.depth = depth
    }

    var isDeleted: Bool { item?.isDeleted == true || item?.isDead == true || item == nil }
}
// MARK: - SwiftData Saved Story

@Model
class SavedStory {
    @Attribute(.unique) var storyId: Int
    var title: String
    var author: String
    var score: Int
    var commentCount: Int
    var url: String?
    var savedAt: Date
    var note: String
    var isRead: Bool
    var domainName: String?

    init(from item: HNItem) {
        self.storyId = item.id
        self.title = item.title ?? "Untitled"
        self.author = item.by ?? "unknown"
        self.score = item.score ?? 0
        self.commentCount = item.commentCount
        self.url = item.url
        self.savedAt = Date()
        self.note = ""
        self.isRead = false
        self.domainName = item.domainName
    }
}
