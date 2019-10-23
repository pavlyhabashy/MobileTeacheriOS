//
//  TagTVCell.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/22/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit



class TagTVCell: UITableViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var switchStatus: UISwitch!
    
    typealias SwitchCallback = (Bool) -> Void
    var switchCallback: SwitchCallback?
    
    var tagObject: Objects!

    func setTag(tag: Objects) {
        tagObject = tag
        tagLabel.text = "\(String(tag.tag)) (\(tag.list.count))"
        switchStatus.setOn(tag.selected, animated: false)
    }


    @IBAction func switchTapped(_ sender: UISwitch) {
        switchCallback?(sender.isOn)
    }

}
