//
//  BrowseTableViewController.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 9/7/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import MessageUI
import SafariServices
import AVKit
import SkeletonView



var downloadTask: URLSessionDownloadTask?
var globalTags = [String:[Video]]()



class BrowseTVC: UITableViewController, VideoCellDelegate, AVPlayerViewControllerDelegate, SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    
    var videos = [Video]()
    var selectedVideos = [Video]()
    var allVideos = [Video]()
    var tags = [String:[Video]]()
    let db = Firestore.firestore()
    var player = AVPlayer()
    var playerVC = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.shared.browseTVC = self
        self.tableView.allowsSelection = false
        self.readDatabase()
        
        playerVC.delegate = self
        
        if #available(iOS 13.0, *) {
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        videos.removeAll()
//        selectedVideoTags.removeAll()
//        allVideos.removeAll()
//        tags.removeAll()
//        globalTags.removeAll()
//        objectArray.removeAll()
    }
    
    override func viewDidLayoutSubviews() {
        view.layoutSkeletonIfNeeded()
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "VideoCell"
    }
    
    func updateTableView(taggedVideos: Set<Video>) {
        if taggedVideos.count > 0 {
            videos = Array(taggedVideos)
        } else {
            videos = allVideos
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if videos.count == 0 {
            return 5
        }
        return videos.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
        cell.delegate = self
        if videos.count > 0 {
            cell.hideAnimation()
            cell.setVideo(video: videos[indexPath.row])
        }
        return cell
    }
    
    
    // Read from the database
    fileprivate func readDatabase() {
        self.tags.removeAll()
        globalTags.removeAll()
        objectArray.removeAll()
        let settings = db.settings
        db.settings = settings
        
        db.collection("videos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //                print(querySnapshot!.documents.count)
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
                    
                    let string = video.url.absoluteString
                    if string.contains("id=") {
                        
                        let array = string.components(separatedBy: "id=")
                        
                        video.downloadURL = URL(string: "https://drive.google.com/uc?export=download&id=\(array[1])")
                        
                    } else if string.contains("/file/d") {
                        let array = string.components(separatedBy: "/")
                        video.downloadURL = URL(string: "https://drive.google.com/uc?export=download&id=\(array[5])")
                    } else {
                        print("nope")
                    }
                    
                    if let storage = document.get("storage") as? String {
                        video.storage = storage
                        print(storage)
                    }
                    
                    // Get tags
                    var str = document.get("tags") as! String
                    str = str.capitalizingFirstLetter()
                    video.tags = str.components(separatedBy: ", ")
                    
                    // Add videos to 'tags' dictionary
                    for i in video.tags {
                        var list = self.tags[i.capitalizingFirstLetter()] ?? []
                        list.append(video)
                        self.tags[i.capitalizingFirstLetter()] = list
                    }
                    
                    self.videos.append(video)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.allVideos = self.videos
                    globalTags = self.tags
                    
                    for (key, value) in globalTags {
                        objectArray.append(Objects(tag: key, selected: false, list: value))
                    }
                    objectArray.sort { $0.tag < $1.tag }
                }
            }
        }
    }
    
    // Converts seconds into hours, minutes, and seconds
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func didTapPlayButton(url: URL) {
        
        let newUrl = url.absoluteString.replacingOccurrences(of: "https://", with: "googledrive://")
        if UIApplication.shared.canOpenURL(NSURL(string: newUrl)! as URL) {
            UIApplication.shared.open(NSURL(string: newUrl)! as URL, options: [:], completionHandler: nil)
        } else {
            // Open the URL in Safari View Controller. You can the following
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
            safariVC.delegate = self
        }
    }
    
    func didTapShareButton(url: URL) {
        
        // Bring up Share Sheet
        let items = [url]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
        
    }
    
    // Tapping the download button starts downloading the video.
    // Once it's done, an AV Player will pop up asynchronously.
    // Currently does not work.
    func didTapDownloadButton(url: String) {
        
        print("Attempting to download file")
        
        // Cancel previous task
        //        downloadTask?.cancel()
        //
        //        // Initialize download
        //        let operationQueue = OperationQueue()
        //        let configuration = URLSessionConfiguration.default
        //        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        //
        //        downloadTask = urlSession.downloadTask(with: url)
        //                downloadTask?.resume()
        
        let vidRef = Storage.storage().reference().child(url)
        
        vidRef.downloadURL{url, error in
            if error != nil{
                print(error!)
                return
            } else {
                
                let asset = AVAsset(url: url!)
                
                print("Duration of Video from Firebase:\(CMTimeGetSeconds(asset.duration))")
                vidRef.getMetadata { metadata, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                    } else {
                        // Metadata now contains the metadata for 'images/forest.jpg'
                        let size = Double(metadata!.size) / 1024.0 / 1024.0
                        print(Double(round(100*size)/100))
                    }
                }
                
                //print("URL")
                //print(url)
                
                self.player = AVPlayer(url: url!)
                self.playerVC.player = self.player
                self.present(self.playerVC, animated: true) {
                    self.player.play()
                }
            }
        }
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

extension UITableViewController: SFSafariViewControllerDelegate, MFMessageComposeViewControllerDelegate, URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //        print("finsished downloading file")
        //        print(location)
        //
        //        DispatchQueue.main.async {
        //            let player = AVPlayer(url: location)  // video path coming from above function
        //
        //            let playerViewController = AVPlayerViewController()
        //            playerViewController.player = player
        //            self.present(playerViewController, animated: true) {
        //                playerViewController.player!.play()
        //            }
        //        }
        
        
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
