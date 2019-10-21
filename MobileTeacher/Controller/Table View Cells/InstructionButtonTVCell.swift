//
//  InstructionButtonTVCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/15/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

protocol InstructionCellDelegate {
    func didTapDownload(url: URL)
}

class InstructionButtonTVCell: UITableViewCell {
    
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    var delegate: InstructionCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        downloadButtonOutlet.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func downloadDriveButtonTapped(_ sender: Any) {
        delegate?.didTapDownload(url: URL(string: "itms-apps://apps.apple.com/us/app/google-drive/id507874739")!)
        // https://apps.apple.com/us/app/google-drive/id507874739
        print("tapped")
    }
    
}
