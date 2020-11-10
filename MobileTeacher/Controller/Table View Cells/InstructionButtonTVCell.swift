//
//  InstructionButtonTVCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/15/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

protocol InstructionCellDelegate {
    func didTapDownload(url: URL, buttonType: String)
    
}

class InstructionButtonTVCell: UITableViewCell {
    
    @IBOutlet weak var downloadButtonOutlet: UIButton!
    var delegate: InstructionCellDelegate?
    var url: URL!
    var buttonType: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //downloadButtonOutlet.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func downloadDriveButtonTapped(_ sender: Any) {
        delegate?.didTapDownload(url: url, buttonType: buttonType)
    }
}
