//
//  VideoTableViewCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/9/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import SkeletonView
//import TagListView

protocol VideoCellDelegate {
    func didTapPlayButton(url: URL)
    func didTapShareButton(url: URL)
    func didTapDownloadButton(video: Video)
    func didTapProblemButton(video: Video)
    func didTapOfflineButton(video: Video )
}

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var shareButtonOutlet: UIButton!
    @IBOutlet weak var videoLengthLabel: UILabel!
    @IBOutlet weak var videoLengthContainer: UIView!
    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    @IBOutlet weak var stackViewOutlet: UIStackView!
    @IBOutlet weak var problemButtonOutlet: UIButton!
    
    
    var videoItem: Video!
    var delegate: VideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoLengthContainer.layer.cornerRadius = 4
        playButtonOutlet.showsTouchWhenHighlighted = false
        playButtonOutlet.titleLabel?.isHidden = true
        downloadButtonOutlet.titleLabel?.isHidden = true
        shareButtonOutlet.titleLabel?.isHidden = true
        [titleLabel, descriptionLabel, ContainerView,  videoLengthLabel, videoLengthContainer, cellContainerView, stackViewOutlet, playButtonOutlet, downloadButtonOutlet, shareButtonOutlet].forEach {
            
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .light {
                    $0?.showAnimatedGradientSkeleton()
                } else {
                    let gradient = SkeletonGradient(baseColor: .secondarySystemBackground)
                    $0?.showAnimatedGradientSkeleton(usingGradient: gradient)
                }
            } else {
                $0?.showAnimatedGradientSkeleton()
            }
        }
        
        
    }
    
    func setVideo(video: Video) {
        videoItem = video
        titleLabel.text = "\(video.title)"
        descriptionLabel.text = video.description
        videoLengthLabel.text = "\(video.minutes):\(String(format: "%02d", video.seconds))"
    }
    
    func hideAnimation() {
        [titleLabel, descriptionLabel, ContainerView, videoLengthLabel, videoLengthContainer, cellContainerView, stackViewOutlet, playButtonOutlet, downloadButtonOutlet, shareButtonOutlet].forEach {
            $0?.hideSkeleton(transition: .crossDissolve(0.25))
        }
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.didTapPlayButton(url: videoItem.downloadURL)
        print("URLLLL")
        print(videoItem.downloadURL)
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        delegate?.didTapShareButton(url: videoItem.url)
    }
    @IBAction func downloadButtonTapped(_ sender: Any) {
        print("Download Press")
        
//        delegate?.didTapDownloadButton(video: videoItem)
        delegate?.didTapOfflineButton(video: videoItem)
    }
    
    @IBAction func problemButtonTapped(_ sender: Any) {
        delegate?.didTapProblemButton(video: videoItem)
    }
    
}

extension UIButton {
    func selectedButton(title:String, iconName: String, widthConstraints: NSLayoutConstraint){
        self.backgroundColor = UIColor(red: 0, green: 118/255, blue: 254/255, alpha: 1)
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.setImage(UIImage(named: iconName), for: .normal)
        self.setImage(UIImage(named: iconName), for: .highlighted)
        let imageWidth = self.imageView!.frame.width
        let textWidth = (title as NSString).size(withAttributes:[NSAttributedString.Key.font:self.titleLabel!.font!]).width
        let width = textWidth + imageWidth + 24
        //24 - the sum of your insets from left and right
        widthConstraints.constant = width
        self.layoutIfNeeded()
    }
}
