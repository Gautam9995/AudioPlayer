//
//  VideosModel.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 21/12/24.
//

import Foundation

// MARK: - VideoResponse
struct VideoResponse: Codable {
    let videos: [Video]
}

// MARK: - Video
struct Video: Codable {
    let id, userID: Int
    let username: String
    let profilePicURL: String
    let description, topic: String
    let viewers, likes: Int
    let video: String
    let thumbnail: String
}

