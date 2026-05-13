//
//  StoryDetail.swift
//  HackNewsReader
//
//  Created by REAL  on 13/05/26.
//
import Foundation
import Observation

@Observable
class StoryDetailViewModel {
    var story: HNItem
    var comments: [CommentNode] = []
    var isLoadingComments = false
    var commentsError: String?

    init(story: HNItem) {
        self.story = story
    }

    func loadComments() async {
        guard comments.isEmpty, !isLoadingComments else { return }
        guard !story.childIds.isEmpty else { return }

        isLoadingComments = true
        commentsError = nil

        comments = await HNAPIService.shared.fetchCommentTree(ids: story.childIds)
        isLoadingComments = false
    }
}

