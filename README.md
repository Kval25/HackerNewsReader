# HackerNews Reader

A clean, native iOS Hacker News client built with SwiftUI and iOS 17+ features.

---

## Features

- Top stories feed with rank, score, author, domain, and comment count
- Threaded comments with collapsible nested replies
- Tap any story title to read the full article in Safari
- Save / unsave stories with one tap — persists across launches
- Attach personal notes to any saved story
- Search saved stories by title, author, domain, or note content
- Read / unread tracking with orange dot indicator
- Feed switcher — Top, New, Best, Ask HN, Show HN
- Pull to refresh
- Pagination (loads 30 stories at a time)
- Full dark mode support
- Haptic feedback throughout

---

## Setup Steps

1. Clone the repo
git clone https://github.com/Kval25/HackerNewsReader.git
2. Open `HackNewsReader.xcodeproj` in Xcode 15+
3. Select your Team under Signing & Capabilities
4. Select a simulator or real device running iOS 17+
5. Press ⌘R to build and run

No API keys, no external packages, no configuration needed.
The app uses the public Hacker News Firebase API directly.

---

## Architecture
HackNewsReader/
├── Model/
│   └── HackNewsModel.swift          # HNItem, FeedType, CommentNode, SavedStory
├── Services/
│   └── HackNewsAPIService.swift      # Actor-based API service, AsyncSemaphore
├── ViewModel/
│   ├── Stories.swift
│   ├── StoryDetail.swift
│   └── SavedStories.swift
└── Views/
├── ContentView.swift
├── StoriesView.swift
├── StoryRowView.swift
├── StoryDetailView.swift
├── CommentView.swift
├── SavedView.swift
├── SavedStoryDetailView.swift
└── NoteEditorView.swift
- **Swift actors** for all network calls — no data races
- **@Observable** macro (iOS 17) instead of ObservableObject
- **SwiftData** for persistent storage of saved stories and notes
- **AsyncSemaphore** actor to limit concurrent API requests to 8
- **CommentNode** owns its own collapsed state — O(1) collapse with no list reload

---

## AI Usage Notes

### Tools Used
- Claude (Anthropic) — used throughout the project

### Prompts That Worked Well

1. *"Build a Swift actor that fetches a Hacker News comment tree recursively.
   Each node's children should be fetched in parallel using withTaskGroup,
   limited to 8 concurrent requests via a custom AsyncSemaphore actor."*
   — This produced the full HNAPIService and AsyncSemaphore exactly as needed.

2. *"Implement save/unsave toggle for HNItem using SwiftData. Use @Query in
   the view to auto-refresh the bookmark icon state."*
   — Correctly separated persistence logic into ViewModel methods taking
   ModelContext as a parameter.

### Where AI Was Wrong

1. **@StateObject vs @State with @Observable** — Claude initially suggested
   using @StateObject with @Observable which is incorrect. @Observable uses
   @State instead. Caught by reading the Swift documentation and fixing manually.

2. **CommentView opaque return type error** — Claude generated a commentBubble
   computed property that returned two views (Button + Divider) without wrapping
   them, causing a build error. Fixed by wrapping both in a VStack.

### Manual vs AI

| What | How |
|---|---|
| Overall architecture and folder structure | Manual |
| Switching from ObservableObject to @Observable | Manual decision |
| AsyncSemaphore concurrency pattern | AI generated, manually reviewed |
| All SwiftUI view layouts | AI generated, manually reviewed |
| Bug fixes (opaque return type, actor warnings) | Manually identified and fixed |
| GitHub setup and README | Manual |

---

## Requirements

- Xcode 15+
- iOS 17+
- Internet connection
