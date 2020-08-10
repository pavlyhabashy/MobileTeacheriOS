//
//  DownloadVC.swift
//  MobileTeacher
//
//  Created by Willie Shen on 7/17/20.
//  Copyright © 2020 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseStorage
import Photos
import AVKit
import AVFoundation

class DownloadVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var video: Video!
    
    private var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    var photosAsset: PHFetchResult<PHAsset>!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = video.title
        descriptionLabel.text = video.description
        // Do any additional setup after loading the view.
    }
    
    func createAlbum() {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "Mobile Teacher")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject as! PHAssetCollection
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Mobile Teacher")
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                }, completionHandler: { success, error in
                    self.albumFound = success

                    if (success) {
                        let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                        print("Successfully created album")
                        print(collectionFetchResult)
                        self.assetCollection = collectionFetchResult.firstObject as! PHAssetCollection
                    }
            })
        }
    }
    //https://stackoverflow.com/questions/27008641/save-images-with-phimagemanager-to-custom-album
    
    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
      if PHPhotoLibrary.authorizationStatus() == .notDetermined {
        PHPhotoLibrary.requestAuthorization({ (status) in
          self.checkAuthorizationWithHandler(completion: completion)
        })
      }
      else if PHPhotoLibrary.authorizationStatus() == .authorized {
        self.createAlbumIfNeeded { (success) in
          if success {
            completion(true)
          } else {
            completion(false)
          }

        }

      }
      else {
        completion(false)
      }
    }
    
    private func createAlbumIfNeeded(completion: @escaping ((_ success: Bool) -> Void)) {
      if let assetCollection = fetchAssetCollectionForAlbum() {
        // Album already exists
        self.assetCollection = assetCollection
        completion(true)
      } else {
        PHPhotoLibrary.shared().performChanges({
          PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "Mobile Teacher")   // create an asset collection with the album name
        }) { success, error in
          if success {
            self.assetCollection = self.fetchAssetCollectionForAlbum()
            print("Success")
            print(success)
            completion(true)
          } else {
            // Unable to create album
            print("PROBLEM")
            print(error)
            completion(false)
          }
        }
      }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
      let fetchOptions = PHFetchOptions()
      fetchOptions.predicate = NSPredicate(format: "title = %@", "Mobile Teacher")
      let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

      if let _: AnyObject = collection.firstObject {
        return collection.firstObject
      }
      return nil
    }
    
    

    @IBAction func downloadClick(_ sender: Any) {
        
        //DispatchQueue.main.sync{
         //   createAlbum()
        //}
        
        self.checkAuthorizationWithHandler(completion: {_ in
            
            print("Created Album Successfully")
        })
        
        var array = video.downloadURL.absoluteString.components(separatedBy: "id=")
        
        print(array)
        //https://drive.google.com/open?id=1jlgGUrFWtDsGu8DQW5QiZGsm7v6rykB0
        print(video.downloadURL.absoluteString)
        var id = video.downloadURL.absoluteString.dropFirst("https://drive.google.com/open?id=".count)
        //https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
        
        //print(id)
        
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: video.storage)
        
        var url = video.downloadURL

        //pathReference.downloadURL{ url, error in
            var vid = AVAsset(url: url!)
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            
            //vid.creationDate?.setValue(formatter.string(from:date), forKey: "value")
            
            print(vid.creationDate)
            //print(vid.modificationDate)
            //print(vid.isCompatibleWithSavedPhotosAlbum)
            //print(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url!.absoluteString))
            
            let attributes = [
                FileAttributeKey.creationDate: NSDate(),
                FileAttributeKey.modificationDate: NSDate()
            ]
            
            print(NSDate())
           
        
         
            
            let urlData = NSData(contentsOf: url!)
            
            
            let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = docsURL.appendingPathComponent(UUID.init().uuidString + ".mov")
            
            
            
            var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            
            _ = URLSession.shared.dataTask(with: request){ data, response, error in
                
                if error != nil{
                    print("Some error occured")
                    return
                }
                
                if let response = response as? HTTPURLResponse{
                    if response.statusCode == 200{
                        DispatchQueue.main.async{
                            if let data = data{
                                if let _ = try? data.write(to: destinationURL, options: Data.WritingOptions.atomic){
                                    print(destinationURL)
                                    print("Converting format")
                                    let preset = AVAssetExportPresetHighestQuality
                                    let outFileType = AVFileType.mov
                                    
                                    /*do{
                                        try FileManager.default.setAttributes(attributes, ofItemAtPath:destinationURL.path)
                                    }catch{
                                        print(error)
                                    }*/
                                    
                                    AVAssetExportSession.determineCompatibility(ofExportPreset: preset,
                                                                                with: vid, outputFileType: outFileType) { isCompatible in
                                        guard isCompatible else
                                        { print("Not compatible")
                                            return }
                                        // Compatibility check succeeded, continue with export.
                                    }
                                    //https://developer.apple.com/documentation/avfoundation/media_assets_and_metadata/exporting_video_to_alternative_formats
                                    guard let exportSession = AVAssetExportSession(asset: vid,
                                                                                   presetName: preset) else { return }
                                    exportSession.outputFileType = outFileType
                                    exportSession.outputURL = destinationURL
                                    exportSession.exportAsynchronously {
                                        // Handle export results.
                                        print(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationURL.path))//https://medium.com/@Dougly/persisting-image-data-locally-swift-3-8bae72673f8a
                                        
                                        //https://www.tutorialspoint.com/how-to-download-a-video-using-a-url-and-save-it-in-an-photo-album-using-swift
                                        DispatchQueue.main.async {
                                            print("Downloading to gallery")
                                            PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                                                
                                                if authorizationStatus == .authorized { //https://stackoverflow.com/questions/35503723/swift-downloading-video-with-downloadtaskwithurl
                                                    urlData!.write(toFile:destinationURL.absoluteString, atomically: true) //https://stackoverflow.com/questions/39543214/declaring-url-in-swift-3/39546882
                                                    PHPhotoLibrary.shared().performChanges({
                                                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                                                        let assetPlaceholder = assetChangeRequest?.placeholderForCreatedAsset
                                                        print(self.assetCollection)
                                                        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)

                                                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset)
                                                        albumChangeRequest!.addAssets([assetPlaceholder!] as NSFastEnumeration)
                                                        
                                                    }){ complete, error in
                                                        if complete {
                                                            print("Complete")
                                                            
                                                        }
                                                
                                                        if error != nil{
                                                            print(error)
                                                        }
                                                
                                                    }
                                                }
                                            })
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                            }else{
                                print("Error")
                            }
                        }
                    }
                }
                
            }.resume()
            

            
            //print(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationURL.absoluteString))
            
            
            /*
            DispatchQueue.main.async {
                print("Downloading to gallery")
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                    
                    if authorizationStatus == .authorized { //https://stackoverflow.com/questions/35503723/swift-downloading-video-with-downloadtaskwithurl
                        urlData!.write(toFile:destinationURL.absoluteString, atomically: true) //https://stackoverflow.com/questions/39543214/declaring-url-in-swift-3/39546882
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                    
                        }){ complete, error in
                            if complete {
                                print("Complete")
                            }
                    
                            if error != nil{
                                print(error)
                            }
                    
                        }
                    }
                })
                
            }
            */
           /* var request = URLRequest(url: url!)
            request.httpMethod = "GET"
            
            _ = URLSession.shared.dataTask(with: request){ data, response, error in
                
                if error != nil{
                    print("Some error occured")
                    return
                }
                
                if let response = response as? HTTPURLResponse{
                    if response.statusCode == 200{
                        DispatchQueue.main.async{
                            if let data = data{
                                if let _ = try? data.write(to: destinationURL, options: Data.WritingOptions.atomic){
                                    print(destinationURL)
                                    print(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationURL.absoluteString))
                                    
                                    //let asset = AVAsset(url: destinationURL)
                                    //let player = AVPlayer(url: destinationURL)
                                    //let playerViewController = AVPlayerViewController()
                                    
                                    //playerViewController.player = player
                                    //self.present(playerViewController, animated:true)
                                    
                                    
                                }
                            }else{
                                print("Error")
                            }
                        }
                    }
                }
                
            }.resume()
            */
            
            //first save the video into the file system
            /*let task = URLSession.shared.downloadTask(with: url!) { localURL, urlResponse, error in
                
                

                
                print(urlResponse)
                print(error)
                
                guard let fileURL = localURL else {return}
                do{
                    let documentsURL = try
                        FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
                    print(savedURL)
                    try FileManager.default.moveItem(at: fileURL, to: savedURL)
                    
                    print(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(savedURL.absoluteString))
                }catch {
                    print("file error: \(error)")
                }
            }
            
             task.resume()
            //then, save the video to the photo album*/
        }
        
       
        
        /*pathReference.downloadURL { url, error in
            if let error = error{
                print(error)
            }else{
                
                let urlData = NSData(contentsOf: url!) ?? nil
                print(urlData)
                DispatchQueue.main.async {
                    print("Trying to get vid")
                    let pic = UIImage(data: urlData as! Data) //http://swiftdeveloperblog.com/code-examples/uiimageview-and-uiimage-load-image-from-remote-url/

                }
                print(pic)
                UIImageWriteToSavedPhotosAlbum(pic!, nil, nil, nil)
                //print(url)
                /*let urlData = NSData(contentsOf: url!) ?? nil
                
                let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                
                //https://www.tutorialspoint.com/how-to-download-a-video-using-a-url-and-save-it-in-an-photo-album-using-swift
                
                
                //download to camera roll
                let filePath="\(galleryPath)/\(UUID().uuidString).mp4"
                
                print(filePath)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url!) //https://stackoverflow.com/questions/29482738/swift-save-video-from-nsurl-to-user-camera-roll
                    
                }){ saved, error in
                    if saved{
                        print("Saved")
                    }
                    if error != nil{
                        print(error)
                    }
                   
                }*/
                /*DispatchQueue.main.async {
                    urlData?.write(toFile: filePath, atomically: true)
                   PHPhotoLibrary.shared().performChanges({
                   PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                   URL(fileURLWithPath: filePath))
                }) {
                   success, error in
                   if success {
                      print("Succesfully Saved")
                   } else {
                      print(error?.localizedDescription)
                   }
                }
                
            }*/
                
            
        }
        
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//}
}

/*extension UIImageView {
    func load(url:URL){
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url){
                if let image = UIImage(data: data){
                    DispatchQueue.main.async{
                        self?.image = image
                    }
                }
            }
            
        }
    }
}*/
