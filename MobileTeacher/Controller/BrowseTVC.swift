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
import FirebaseStorage



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
            return 3
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
        //try to play the video in app
        //TODO: get the video link from firebase!
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let starsRef = storageRef.child("15C567FD-73D1-4F6B-984A-854F49B2DB37.mov")
//        starsRef.downloadURL { (url, error) in

//            print(url?.absoluteString)
//            if let error = error {
//                // Handle any errors
//                // Show unable to play video at this time
//            } else {
//                // Get the download URL for 'images/stars.jpg'
//                if let downloadURL = url{
//                    self.player = AVPlayer(url: downloadURL)
//                    self.playerVC.player = self.player
//
//                    print("downloadUrl obtained and set")
//                    self.present(self.playerVC, animated: true) { () -> Void in
//                        self.playerVC.player?.play()
//                    }
//                }
//            }
//        }
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

           let assetUrl = baseUrl.appendingPathComponent("MyFileSaveName.mp4")

           let url = assetUrl
           print(url)
           let avAssest = AVAsset(url: url)
           let playerItem = AVPlayerItem(asset: avAssest)


           let player = AVPlayer(playerItem: playerItem)

           let playerViewController = AVPlayerViewController()
           playerViewController.player = player

           self.present(playerViewController, animated: true, completion: {
               player.play()
           })

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
        
        // Deprecated
//        let alert: UIAlertView = UIAlertView(title: "Title", message: "Please wait...", delegate: nil, cancelButtonTitle: "Cancel")
//
//
//        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
//        loadingIndicator.center = self.view.center
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.style = UIActivityIndicatorView.Style.gray
//        loadingIndicator.startAnimating();
//
//        alert.setValue(loadingIndicator, forKey: "accessoryView")
//        loadingIndicator.startAnimating()
//
//        alert.show()
        
//        FIRStorage.storage().referenceForURL(detailFullsizeUrl).metadataWithCompletion { (metadata, error) in
//        if error != nil{
//            print("error getting metadata")
//        } else {
//            let downloadUrl = metadata?.downloadURL()
//            print(downloadUrl)
//
//            if downloadUrl != nil{
//                self.avPlayer = AVPlayer(URL: downloadUrl!)
//                self.avPlayerViewController.player = self.avPlayer
//                print("downloadUrl obtained and set")
//            }
//        }
        
//        let vidRef = Storage.storage().reference().child(url)
//
//        vidRef.downloadURL{url, error in
//            if error != nil{
//                print(error!)
//                return
//            } else {
//
//                let asset = AVAsset(url: url!)
//
//                print("Duration of Video from Firebase:\(CMTimeGetSeconds(asset.duration))")
//                vidRef.getMetadata { metadata, error in
//                    if let error = error {
//                        // Uh-oh, an error occurred!
//                    } else {
//                        // Metadata now contains the metadata for 'images/forest.jpg'
//                        let size = Double(metadata!.size) / 1024.0 / 1024.0
//                        print(Double(round(100*size)/100))
//                    }
//                }
//
//                //print("URL")
//                //print(url)
//
//                self.player = AVPlayer(url: url!)
//                self.playerVC.player = self.player
//                self.present(self.playerVC, animated: true) {
//                    self.player.play()
//                }
//            }
//        }
//    }
    
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let starsRef = storageRef.child("15C567FD-73D1-4F6B-984A-854F49B2DB37.mov")
    starsRef.downloadURL { (url, error) in

        print(url?.absoluteString)
        if let error = error {
            // Handle any errors
            // Show unable to play video at this time
        } else {
            // Get the download URL for 'images/stars.jpg'
            if let downloadURL = url{
                let videoUrl = downloadURL.absoluteString
                let session = URLSession.shared
                let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                let destinationUrl = docsUrl.appendingPathComponent("MyFileSaveName.mp4")
                if(FileManager().fileExists(atPath: destinationUrl.path)){
                        print("\n\nfile already exists\n\n")
                }
                else{
                    //DispatchQueue.global(qos: .background).async {
                    var request = URLRequest(url: URL(string: videoUrl)!)
                    request.httpMethod = "GET"
                    _ = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    if(error != nil){
                        print("\n\nsome error occured\n\n")
                        return
                    }
                    if let response = response as? HTTPURLResponse{
                        if response.statusCode == 200{
                            DispatchQueue.main.async {
                                if let data = data{
                                    if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic){
                                        print("\n\nurl data written\n\n")
                                    }
                                    else{
                                        print("\n\nerror again\n\n")
                                    }
                                }//end if let data
                            }//end dispatch main
                        }//end if let response.status
                    }
                }).resume()
                            //}//end dispatch global
                        }//end outer else
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
