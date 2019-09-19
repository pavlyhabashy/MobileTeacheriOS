//
//  VideoTableViewCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/9/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

protocol VideoCellDelegate {
    func didTapPlayButton(url: URL)
    func didTapShareButton(url: URL)
}

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ContainerView: UIView!
    
    var videoItem: Video!
    var delegate: VideoCellDelegate?
    
    func setVideo(video: Video) {
        videoItem = video
        titleLabel.text = video.title
        descriptionLabel.text = video.description
        
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.didTapPlayButton(url: videoItem.url)
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        delegate?.didTapShareButton(url: videoItem.url)
    }
    
}
