import Foundation

// MARK: - HackNews API Service

actor HNAPIService {
    static let shared = HNAPIService()
    private let baseURL = "https://hacker-news.firebaseio.com/v0"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.urlCache = URLCache(memoryCapacity: 20_000_000, diskCapacity: 50_000_000)
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }

    // MARK: - Feed

    func fetchStoryIds(feed: FeedType) async throws -> [Int] {
        let url = URL(string: "\(baseURL)/\(feed.rawValue).json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([Int].self, from: data)
    }

    func fetchItem(id: Int) async throws -> HNItem {
        let url = URL(string: "\(baseURL)/item/\(id).json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(HNItem.self, from: data)
    }

    // MARK: - Batch fetch

    func fetchItems(ids: [Int], maxConcurrent: Int = 8) async throws -> [HNItem] {
        try await withThrowingTaskGroup(of: HNItem?.self) { group in
            let semaphore = AsyncSemaphore(limit: maxConcurrent)
            for id in ids {
                group.addTask {
                    await semaphore.wait()
                    defer { Task { await semaphore.signal() } }
                    return try? await self.fetchItem(id: id)
                }
            }
            var items: [HNItem] = []
            for try await item in group {
                if let item { items.append(item) }
            }
            let idOrder = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
            return items.sorted { (idOrder[$0.id] ?? 0) < (idOrder[$1.id] ?? 0) }
        }
    }

    // MARK: - Comments (recursive)

    func fetchCommentTree(ids: [Int], depth: Int = 0, maxDepth: Int = 6) async -> [CommentNode] {
        guard depth < maxDepth, !ids.isEmpty else { return [] }

        return await withTaskGroup(of: CommentNode?.self) { group in
            for id in ids {
                group.addTask {
                    guard let item = try? await self.fetchItem(id: id) else {
                        return CommentNode(id: id, item: nil, depth: depth)
                    }
                    let childIds = item.childIds
                    let children = await self.fetchCommentTree(ids: childIds, depth: depth + 1, maxDepth: maxDepth)
                    return CommentNode(id: id, item: item, children: children, depth: depth)
                }
            }
            var nodes: [CommentNode] = []
            for await node in group {
                if let node { nodes.append(node) }
            }
            let idOrder = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
            return nodes.sorted { (idOrder[$0.id] ?? 0) < (idOrder[$1.id] ?? 0) }
        }
    }
}

// MARK: - Async Semaphore

actor AsyncSemaphore {
    private var count: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(limit: Int) { self.count = limit }

    func wait() async {
        if count > 0 {
            count -= 1
        } else {
            await withCheckedContinuation { continuation in
                waiters.append(continuation)
            }
        }
    }

    func signal() {
        if waiters.isEmpty {
            count += 1
        } else {
            let waiter = waiters.removeFirst()
            waiter.resume()
        }
    }
}
