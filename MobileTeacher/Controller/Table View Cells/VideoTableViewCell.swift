//
//  VideoTableViewCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/9/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

protocol VideoCellDelegate {
    func didTapPlayButton(title: String)
    func didTapDownloadButton(url: String)
}

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var delegate: VideoCellDelegate?
    
    @IBAction func playButtonTapped(_ sender: Any) {
        delegate?.didTapPlayButton(title: "title")
    }
    @IBAction func downloadButtonTapped(_ sender: Any) {
        delegate?.didTapDownloadButton(url: "url")
    }
    
}
