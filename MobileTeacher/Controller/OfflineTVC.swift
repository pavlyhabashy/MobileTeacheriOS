//
//  OfflineTVC.swift
//  MobileTeacher
//
//  Created by Alfonso Rojas on 10/5/20.
//  Copyright © 2020 Pavly Habashy. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MessageUI

class OfflineTVC: UITableViewController,OfflineVideoCellDelegate, UITabBarControllerDelegate {
    
    var urlArr = [URL]()
    var videos_arr = [OfflinedVideo]()
    var docURL: URL?
    @IBOutlet weak var backButton: UIBarButtonItem!
    var deletedVideos = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        backButton.title = "Home"
         
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        
        loadDocumentData()
        tableView?.reloadData()
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if videos_arr.count == 0{
//            return 3
//        }
        return videos_arr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfflineCell", for: indexPath) as! OfflineTableViewCell
        cell.delegate = self
        if videos_arr.count > 0 {
            cell.hideAnimation()
            let ov = videos_arr[indexPath.row]
            let v = Video(title: ov.title, description: ov.description, tags: ov.tags, url: ov.url, downloadURL: ov.downloadURL, hours: ov.hours, minutes: ov.minutes, seconds: ov.seconds, downloadLocation: ov.downloadLocation, storage: "")
            cell.setVideo(video: v)
        }

        return cell
    }
    
    func loadDocumentData(){
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
       let decoder = PropertyListDecoder()
       guard let data = try? Data.init(contentsOf: documents.appendingPathComponent("Preferences.plist")),
           var videos = try? decoder.decode(Plist.self, from: data)
           else { return }
       videos_arr = videos.videos
       let fileManager = FileManager.default
       let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
       docURL = documentsURL
       do {
           let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
           urlArr=fileURLs
       } catch {
           print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
       }
    }
    

    func didTapPlayButton(url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
        playerViewController.player!.play()
    }
    }
    
    func didTapShareButton(url: URL) {
        // Bring up Share Sheet
        let items = [url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func didTapProblemButton(video: Video) {
        let title = video.title
        print(title)
        let description = video.description
        //check to see if device can compose email
        guard MFMailComposeViewController.canSendMail() else{return}
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["mobileteacher.org@gmail.com"])
        mailComposer.setSubject("Reporting a problem on "+title)
        mailComposer.setMessageBody("Hello, \nI am reporting a problem on the following video: "+title+".", isHTML: false)
        present(mailComposer,animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            deleteVideoFile(video: videos_arr[indexPath.row])
            deletedVideos += 1
            videos_arr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func deleteVideoFile(video: OfflinedVideo){
        let deleteURL = video.downloadLocation
        let deleteURLString = video.downloadLocation.absoluteString
        let array = deleteURLString.components(separatedBy: "/")
        guard let originalFile = array.last else{return}
        guard let fileNameToDelete = originalFile.removingPercentEncoding else {return}
        print("FILENAME TO DELETE \(fileNameToDelete)")
                var filePath = ""
                // Fine documents directory on device
                 let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                
                if dirs.count > 0 {
                    let dir = dirs[0] //documents directory
                    filePath = dir.appendingFormat("/\(fileNameToDelete)")
                    print("Local path = \(filePath)")
         
                } else {
                    print("Could not find local directory to store file")
                    return
                }
                
                
                do {
                     let fileManager = FileManager.default
                    
                    // Check if file exists
                    if fileManager.fileExists(atPath: filePath) {
                        // Delete file
                        try fileManager.removeItem(atPath: filePath)
                    } else {
                        print("File does not exist")
                    }
         
                }
                catch let error as NSError {
                    print("An error took place: \(error)")
                }
//        print(array.last)
//        do{
//            let fileManager = FileManager.default
//            if fileManager.fileExists(atPath: deleteURLString){
//                try fileManager.removeItem(at: deleteURL)
//            }else{
//                print(deleteURL)
//                print("File does not exist")
//                print(deleteURLString)
//            }
//        }catch let error as NSError{
//            print(error)
//        }
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        if deletedVideos == 0{
            return
        }
        guard let myURL = docURL else{return}
        let path_new = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Preferences.plist")
        do{
            try FileManager.default.removeItem(at: path_new)
            print("SUCCEEDED in Deleting file at path: \(path_new)")
        }catch{
            print("ERROR")
        }
        // write new plist file
        let data_to_plist = Plist(videos: videos_arr)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            try FileManager.default.moveItem(at: myURL, to: myURL)
            let data = try encoder.encode(data_to_plist)
            try data.write(to: path_new)
        } catch {
            print(error)
        }
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }                                                                   FGREF
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


}
