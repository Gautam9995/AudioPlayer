//
//  VideoCollViewCell.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 22/12/24.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import Lottie

class VideoCollViewCell: UICollectionViewCell {

    //MARK: - Identifier
    static var identifier = "VideoCollViewCell"
    
    
    //MARK: - Outlets
    @IBOutlet weak var viewVideo: UIView!
    
    @IBOutlet weak var viewUserDetail: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var viewTopic: UIView!
    @IBOutlet weak var lblTopic: UILabel!
    
    @IBOutlet weak var viewLive: UIView!
    @IBOutlet weak var lblPopularLive: UILabel!
    
    @IBOutlet weak var viewViewerCount: UIView!
    @IBOutlet weak var lblViewerCount: UILabel!

    @IBOutlet weak var viewExplore: UIView!
    @IBOutlet weak var lblExplore: UILabel!
    
    @IBOutlet weak var viewCount: UIView!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var viewHeartAnimation: AnimationView!
    
    
    //MARK: - Varibales
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var isVideoPlay: Bool = false
    
    
    //MARK: - Initial
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        setupGestures()
        setupPlayerLayer()
        addNotification()
    }

    //MARK: - Override
    override func prepareForReuse() {
        super.prepareForReuse()
        resetPlayer()
        playerLayer?.player = nil
    }
    
    //MARK: - Configure Details
    func configure(_ videoDetail: Video) {
        loadVideo(urlStr: videoDetail.video)
        setupDetaills(details: videoDetail)
    }
    
    //MARK: - Video Load, PlayerSetUp & Play
    func loadVideo(urlStr: String) {
        player = AVPlayer(url: URL(string: urlStr)!)
        playerLayer?.player = player
    }
    
    func playVideo() {
        self.setPlayButton(isPlay: true)
        self.player?.play()
    }
    
    private func setupPlayerLayer() {
        let playerView = UIView(frame: self.viewVideo.bounds)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewVideo.addSubview(playerView)
        
        playerLayer = AVPlayerLayer()
        playerLayer?.frame = ScreenBounds
        playerLayer?.videoGravity = .resizeAspectFill
        playerView.layer.addSublayer(playerLayer!)
    }
    
    //Reset Player when scroll to next item
    func resetPlayer() {
        self.setPlayButton(isPlay: false)
        self.player?.pause()
    }
    
    //Manage buton for Play Pause for Tap
    private func setPlayButton(isPlay: Bool) {
        isVideoPlay = isPlay
        imgPlay.isHidden = isVideoPlay
    }
    
    //MARK: - Actions
    @IBAction func btnFollow(_ sender: Any) {
    }
}


//MARK: - UI & Detail Setup
extension VideoCollViewCell {
    
    private func setupUI() {
        viewUserDetail.layer.cornerRadius = 8
        imgUser.layer.cornerRadius = 6
        btnFollow.layer.cornerRadius = 8
        viewTopic.layer.cornerRadius = 6
        viewLive.layer.cornerRadius = 6
        viewViewerCount.layer.cornerRadius = 6
        viewCount.layer.cornerRadius = 6
        
        DispatchQueue.main.async {
            self.viewTime.layer.cornerRadius = self.viewTime.bounds.height / 2
            self.viewExplore.layer.cornerRadius = self.viewExplore.bounds.height / 2
        }
        viewExplore.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        
        lblUserName.font = setCustomFont(.medium, 10)
        lblLikeCount.font = setCustomFont(.medium, 10)
        lblTopic.font = setCustomFont(.regular, 10)
        lblPopularLive.font = setCustomFont(.regular, 10)
        btnFollow.titleLabel?.font = setCustomFont(.medium, 12)
        lblViewerCount.font = setCustomFont(.medium, 10)
        lblExplore.font = setCustomFont(.regular, 10)
        lblCount.font = setCustomFont(.medium, 10)
        lblTime.font = setCustomFont(.regular, 7)
        
        lblCount.attributedText = createAttributedStringWithColorChange(from: "1/5", targetText: "1", targetColor: UIColor(named: "countTextColor")!)
        
        viewHeartAnimation.animation = Animation.named("floatingHearts")
    }
    
    private func setupGestures() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
                doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imgUser.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlePlayPauseOnTap))
        viewVideo.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupDetaills(details: Video) {
        imgUser.sd_setImage(with: URL(string: details.profilePicURL), placeholderImage: UIImage(named: "ic_user"))
        lblUserName.text = details.username
        lblLikeCount.text = String(details.likes)
        lblTopic.text = details.topic
        lblPopularLive.text = "Popular Live"
        lblViewerCount.text = String(details.viewers)
    }
}

//MARK: - Gesture Methods
extension VideoCollViewCell {
    @objc func handlePlayPauseOnTap() {
        isVideoPlay = !isVideoPlay
        setPlayButton(isPlay: isVideoPlay)
        if isVideoPlay {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    @objc func handleDoubleTap() {
        viewHeartAnimation.currentProgress = 0.0
        viewHeartAnimation.play()
    }
}

//MARK: - NotificationCenter
extension VideoCollViewCell {
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlayerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
}

//MARK: - Video Loop
extension VideoCollViewCell {
    @objc func videoPlayerDidFinishPlaying() {
        if self.window != nil && isVideoPlay {
            player?.seek(to: CMTime.zero)
            player?.play()
        } else {
            resetPlayer()
        }
    }
}
