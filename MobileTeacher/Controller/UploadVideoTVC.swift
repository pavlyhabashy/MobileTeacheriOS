//
//  UploadVideoTVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/2/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

class UploadVideoTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.allowsSelection = false
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeholderCell: UITableViewCell = UITableViewCell()
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadStepOne", for: indexPath)
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadStepTwo", for: indexPath)  as! InstructionButtonTVCell
            cell.delegate = self
            cell.url = URL(string: "https://docs.google.com/forms/d/1ojgGZX6K4XeZvpdfLWEWdmO6mn_i62tLmrWAV0uVAMo/viewform")!
            cell.buttonType = "openURL"
            return cell
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadStepThree", for: indexPath)
            return cell
        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UploadStepFour", for: indexPath)
            return cell
        }

        return placeholderCell
    }
    

    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }
    
}
