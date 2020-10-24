//
//  OfflineTableViewCell.swift
//  MobileTeacher
//
//  Created by Alfonso Rojas on 10/12/20.
//  Copyright © 2020 Pavly Habashy. All rights reserved.
//

import UIKit
import SkeletonView

protocol OfflineVideoCellDelegate{
    func didTapPlayButton(url: URL)
    func didTapShareButton(url: URL)
    func didTapProblemButton(video: Video)
}
class OfflineTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var videoLengthLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var cellContainerView: UIView!
    @IBOutlet weak var stackViewOutlet: UIStackView!
    @IBOutlet weak var videoLengthContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    var videoItem: Video!
    var delegate: OfflineVideoCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        videoLengthContainer.layer.cornerRadius = 4
        playButton.showsTouchWhenHighlighted = false
        playButton.titleLabel?.isHidden = true
        shareButton.titleLabel?.isHidden = true
        [titleLabel, descriptionLabel, containerView,  videoLengthLabel, videoLengthContainer, cellContainerView, stackViewOutlet, playButton, shareButton].forEach {
            
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
    
    func setVideo(video: Video){
        videoItem = video
        titleLabel.text = video.title
        descriptionLabel.text = video.description
        videoLengthLabel.text = "\(video.minutes):\(String(format: "%02d", video.seconds))"
    }
    func hideAnimation() {
        [titleLabel, descriptionLabel, containerView, videoLengthLabel, videoLengthContainer, cellContainerView, stackViewOutlet, playButton, shareButton].forEach {
            $0?.hideSkeleton(transition: .crossDissolve(0.25))
        }
    }
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.didTapPlayButton(url: videoItem.downloadLocation)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        delegate?.didTapShareButton(url: videoItem.downloadLocation)

    }
    
    
    @IBAction func problemButtonTapped(_ sender: Any) {
        delegate?.didTapProblemButton(video: videoItem)
    }

}
//extension UIButton {
//    func selectedButton(title:String, iconName: String, widthConstraints: NSLayoutConstraint){
//        self.backgroundColor = UIColor(red: 0, green: 118/255, blue: 254/255, alpha: 1)
//        self.setTitle(title, for: .normal)
//        self.setTitle(title, for: .highlighted)
//        self.setTitleColor(UIColor.white, for: .normal)
//        self.setTitleColor(UIColor.white, for: .highlighted)
//        self.setImage(UIImage(named: iconName), for: .normal)
//        self.setImage(UIImage(named: iconName), for: .highlighted)
//        let imageWidth = self.imageView!.frame.width
//        let textWidth = (title as NSString).size(withAttributes:[NSAttributedString.Key.font:self.titleLabel!.font!]).width
//        let width = textWidth + imageWidth + 24
//        //24 - the sum of your insets from left and right
//        widthConstraints.constant = width
//        self.layoutIfNeeded()
//    }
//}
