//
//  BrowseTableViewController.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/7/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import MessageUI
import SafariServices

var videos = [Video]()
let db = Firestore.firestore()

class BrowseTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        readDatabase()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
        cell.delegate = self
        
        cell.setVideo(video: videos[indexPath.row])
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Read from the database
    fileprivate func readDatabase() {
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("videos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var video = Video()
                    
                    // For some reason, the lengths stored in the database are either strings or numbers.
                    // The following block takes care of that.
                    var length: Int
                    if let lengthStr = document.get("length") as? String {
                        length = Int(lengthStr)!
                    } else if let lengthInt = document.get("length") as? Int {
                        length = lengthInt
                    } else {
                        length = 0
                        print("Error")
                    }
                    
                    let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: length)
                    video.hours = h
                    video.minutes = m
                    video.seconds = s
                    
                    video.title = document.get("title") as! String
                    video.description = document.get("description") as! String
                    
                    // Add period to description
                    if video.description.suffix(1) == " " {
                        video.description = String(video.description.dropLast())
                        video.description = video.description + "."
                    }
                    else if video.description.suffix(1) == "." {
                        // Do nothing
                    }
                    else {
                        video.description = video.description + "."
                    }
                    
                    video.url = URL(string: (document.get("url") as! String))!
                    
                    // Get tags
                    var str = document.get("tags") as! String
                    str = str.capitalizingFirstLetter()
                    video.tags = str.components(separatedBy: ", ")
                    
                    videos.append(video)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Converts seconds into hours, minutes, and seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension UITableViewController: VideoCellDelegate, SFSafariViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    func didTapPlayButton(url: URL) {
        // James works here
        
        // Open the URL in Safari View Controller. You can the following
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    func didTapShareButton(url: URL) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "\(url)"
            controller.recipients = []
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // Handles dismissing the Messages controller
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // Handles dismissing the Safari controller
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
