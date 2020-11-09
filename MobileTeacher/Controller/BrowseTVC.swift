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
import Photos


var downloadTask: URLSessionDownloadTask?
var globalTags = [String:[Video]]()



class BrowseTVC: UITableViewController, VideoCellDelegate, AVPlayerViewControllerDelegate, SkeletonTableViewDataSource, SkeletonTableViewDelegate {

    
    
    @IBOutlet weak var backButton: UIBarButtonItem!
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)

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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
                    video.downloadURL = video.url
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
            print("HOLLAA")
            print(assetUrl)
           //let url = assetUrl
           //print(url)
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
    func didTapProblemButton(video: Video) {
           print("Press Problem")
           let title = video.title
           print(title)
           //check to see if device can compose email
           guard MFMailComposeViewController.canSendMail() else{return}
           let mailComposer = MFMailComposeViewController()
           mailComposer.mailComposeDelegate = self
           mailComposer.setToRecipients(["mobileteacher.org@gmail.com"])
           mailComposer.setSubject("Reporting a problem on "+title)
           mailComposer.setMessageBody("Hello, \nI am reporting a problem on the following video: "+title+".", isHTML: false)
           present(mailComposer,animated: true)
       }
    // Tapping the download button starts downloading the video.
    // Once it's done, an AV Player will pop up asynchronously.
    // Currently does not work.
    func didTapDownloadButton(video: Video) {
        
        print("Attempting to download file")
        
        //print(video)
        performSegue(withIdentifier: "downloadSegue", sender: video)
        
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
        print("ABCDEFG")
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
    //if user presses 'yes' then we begin download
    func proceedToDownload(video: Video){
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: video.downloadURL.absoluteString) else { return }
        // intialize temp array
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        print(documentsDirectoryURL)
        // check if the file already exist at the destination folder if you don't want to download it twice
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {

            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                //input the notification banner here
                let content2 = UNMutableNotificationContent()
                content2.title = "Downloading Complete"
                content2.body =  "\"\(video.title)\" has been downloaded to your device"
                //https://docs.swift.org/swift-book/LanguageGuide/StringsAndCharacters.html
                let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request2 = UNNotificationRequest(identifier: "Video Download Success", content: content2, trigger: trigger2)
                UNUserNotificationCenter.current().add(request2, withCompletionHandler: nil)
                // use guard to unwrap your optional url
                guard let location = location else { return }

                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                var videos_for_plist = [OfflinedVideo]()
                        // check for existing videos in the plist
                        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let decoder = PropertyListDecoder()
                //we will write all the metadata of videos to a plist so that we can grab metadata once offline
                if let data = try? Data.init(contentsOf: documents.appendingPathComponent("Preferences.plist")) {
                    let preferences_old = try? decoder.decode(Plist.self, from: data);
                    videos_for_plist.append(contentsOf: preferences_old?.videos ?? []);
                        }
                        let preferences = OfflinedVideo(title: video.title, description : video.description, tags: video.tags, url: videoURL, downloadURL:videoURL, hours: video.hours, minutes: video.minutes, seconds: video.seconds, downloadLocation:destinationURL)
                        let encoder = PropertyListEncoder()
                        encoder.outputFormat = .xml

                        let path_new = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Preferences.plist")
                        // append new video to temp list
                        videos_for_plist.append(preferences)
                        // write new plist file
                        let data_to_plist = Plist(videos: videos_for_plist)
                        do {
                            try FileManager.default.moveItem(at: location, to: destinationURL)
                            let data = try encoder.encode(data_to_plist)
                            try data.write(to: path_new)
                        } catch {
                            print("ERROR\(error)")
                        }
            }.resume()

        } else {
            print("File already exists at destination url")
        }
    }
    //checks to see whether video exists. if it does, then the user won't be prompted to download again
    func fileExists(title: String) -> Bool
    {
        let myManager = FileManager.default
        if let url = myManager.urls(for: .documentDirectory,
                                  in: .userDomainMask).first {
            let filePath = url.appendingPathComponent("Preferences.plist").path
            print ("filepath: \(filePath)")
            if myManager.fileExists(atPath: filePath){
                if let myArray = NSDictionary(contentsOfFile: filePath){
                    if let videos = myArray["videos"] as? [[String:AnyObject]] {
                        for videoDict in videos {
                            if let thisTitle = videoDict["title"]{
                                if thisTitle as! String == title{
                                    return true
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
   //gets called when user wants to download video
    func didTapOfflineButton(video: Video) {
        //checks to see if video already is downloaded. if it is, then the user will not be prompted.
        if(fileExists(title:video.title)){
            return
        }
        //alert the user that they are about to download
        guard let data = NSData(contentsOf: video.downloadURL) else{
            let alert2 = UIAlertController(title: "Error", message: "You are not connected to the internet. Please try again later.", preferredStyle: .alert)
            //else cancel and return
            alert2.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { action in
                return
            }))
            self.present(alert2, animated: true)
            return
        }
        //grab video size to alert user of how much space video will take up
        var fileSize = Double(data.length)
        fileSize /= (1024*1024)
        let doubleStr = String(format: "%.2f", fileSize)
        //the alert banner
        let alert = UIAlertController(title: "Download Video", message: "You are about to download a file size of \(doubleStr) MB. Do you wish to proceed?", preferredStyle: .alert)
        //if yes, then proceed to download
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            self.proceedToDownload(video: video)
        }))
        //else cancel and return
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            return
        }))
        self.present(alert,animated: true)
    
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
