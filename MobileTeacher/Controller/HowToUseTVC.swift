//
//  InstructionsTableViewController.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/16/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import MessageUI

class HowToUseTVC: UITableViewController, UINavigationControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeholderCell: UITableViewCell = UITableViewCell()
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepOne", for: indexPath) as! InstructionButtonTVCell
            cell.delegate = self
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepTwo", for: indexPath)
            return cell
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepThree", for: indexPath)
            return cell
        } else if (indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepFour", for: indexPath)
            return cell
        } else if (indexPath.row == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepFive", for: indexPath)
            return cell
        } else if (indexPath.row == 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath) as! ContactTVCell
            cell.delegate = self
            return cell
        }

        return placeholderCell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }


}

extension UITableViewController: InstructionCellDelegate, ContactCellDelegate, MFMailComposeViewControllerDelegate {
    
    func didTapContact() {
        let alert = UIAlertController(title: "Contact Us",
                                    message: "If you have any questions or you may have noticed a problem, please let us know.",
                                    preferredStyle: UIAlertController.Style.actionSheet)

        alert.addAction(UIAlertAction(title: "Email",
                                      style: UIAlertAction.Style.default) {
                                        AlertAction in
                                        if !self.sendEmail(type: "") {
                                            self.emailSendingErrorHandler()
                                        }
        })
        alert.addAction(UIAlertAction(title: "Report a Problem",
                                      style: UIAlertAction.Style.default) {
                                        AlertAction in
                                        if !self.sendEmail(type: "Report a Problem") {
                                            self.emailSendingErrorHandler()
                                        }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.cancel))
        
        self.present(alert, animated: true) {
            
        }
        
    }
    
    func sendEmail(type: String) -> Bool {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mobileteacher.org@gmail.com"])
            mail.setSubject(type)

            present(mail, animated: true)
            return true
        }
        return false
    }
    
    func emailSendingErrorHandler() {
        let alert = UIAlertController(title: "Error Composing Email",
                                    message: "We encountered an error sending an email. Email us at mobileteacher.org@gmail.com",
                                    preferredStyle: UIAlertController.Style.actionSheet)

        alert.addAction(UIAlertAction(title: "Copy Email",
                                      style: UIAlertAction.Style.default) {
                                        AlertAction in
                                        UIPasteboard.general.string = "mobileteacher.org@gmail.com"
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.cancel))
        
        self.present(alert, animated: true) {
            
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func didTapDownload(url: URL) {
        UIApplication.shared.open(url, options: [:]) { (success) in
            print(success)
        }
    }
}
