//
//  CommentsModel.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 21/12/24.
//

import Foundation

// MARK: - CommentResponse
struct CommentResponse: Codable {
    let comments: [Comment]
}

// MARK: - Comment
struct Comment: Codable {
    let id: Int
    let username: String
    let picURL: String
    let comment: String
    var isJoined: Bool?
    
    init(id: Int, username: String, picURL: String, comment: String, isJoined: Bool = false) {
        self.id = id
        self.username = username
        self.picURL = picURL
        self.comment = comment
        self.isJoined = isJoined
    }
}

