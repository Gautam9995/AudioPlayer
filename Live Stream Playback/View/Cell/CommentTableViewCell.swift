//
//  CommentTableViewCell.swift
//  Live Stream Playback
//
//  Created by Gautam Variya on 22/12/24.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    //MARK: - Identifier
    static var identifier = "CommentTableViewCell"
    
    //MARK: - Outlets
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    //MARK: - 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    //MARK: - Configure Details
    func configure(_ commentDetail: Comment) {
        setupDetaills(details: commentDetail)
    }
    
    //MARK: - Fade Set for top most comment
    func setFading(isFade: Bool = false) {
        self.contentView.alpha = isFade ? 0.5 : 1
    }
}

//MARK: - UI & Detail Setup
extension CommentTableViewCell {
    
    private func setupUI() {
        DispatchQueue.main.async {
            self.imgUser.layer.cornerRadius = self.imgUser.frame.height / 2
        }
        lblUsername.font = setCustomFont(.semibold, 9)
        lblComment.font = setCustomFont(.regular, 9)
    }
    
    private func setupDetaills(details: Comment) {
        
        if details.isJoined ?? false {
            imgUser.sd_setImage(with: URL(string: details.picURL), placeholderImage: UIImage(named: "ic_hand"))
            lblUsername.attributedText = createAttributedStringWithColorChange(from: "\(details.username) joined", targetText: "joined", targetColor: .white)
            lblComment.isHidden = true
        } else {
            imgUser.sd_setImage(with: URL(string: details.picURL), placeholderImage: UIImage(named: "ic_user"))
            lblUsername.text = details.username
            lblComment.text = details.comment
            lblComment.isHidden = false
        }
    }
}
