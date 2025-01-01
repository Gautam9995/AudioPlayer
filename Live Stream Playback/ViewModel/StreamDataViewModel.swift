//
//  StreamDataViewModel.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 21/12/24.
//

import UIKit

class StreamDataViewModel: ObservableObject {
    @Published var videos: [Video] = [] // Expose the list of videos
    @Published var errorMessageVideo: String? // Expose errors if any
    
    @Published var comments: [Comment] = [] // Expose the list of comments
    @Published var errorMessageComment: String? // Expose errors if any

    init() {
        fetchVideos()
        fetchComments()
    }
    
    //Fetch Videos from json file
    private func fetchVideos() {
        guard let url = Bundle.main.url(forResource: "videosData", withExtension: "json") else {
            errorMessageVideo = "JSON file not found."
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedUsers = try JSONDecoder().decode(VideoResponse.self, from: data)
            videos = decodedUsers.videos
        } catch {
            errorMessageVideo = "Error decoding JSON: \(error)"
        }
    }
    
    //Fetch Comments from json file
    private func fetchComments() {
        guard let url = Bundle.main.url(forResource: "commentsData", withExtension: "json") else {
            errorMessageComment = "JSON file not found."
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedUsers = try JSONDecoder().decode(CommentResponse.self, from: data)
            comments = decodedUsers.comments
        } catch {
            errorMessageComment = "Error decoding JSON: \(error)"
        }
    }
}
