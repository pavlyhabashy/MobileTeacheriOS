//
//  ContactTVCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 11/11/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

protocol ContactCellDelegate {
    func didTapContact()
}

class ContactTVCell: UITableViewCell {
    
    var delegate: ContactCellDelegate?

    @IBOutlet weak var contactUsButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contactUsButton.layer.cornerRadius = 25

        contactUsButton.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func contactButtonPressed(_ sender: Any) {
        delegate?.didTapContact()
    }
    
}
