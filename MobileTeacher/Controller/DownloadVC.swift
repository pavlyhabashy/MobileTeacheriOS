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
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
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
    
    //https://medium.com/@abhimuralidharan/finite-length-tasks-in-background-ios-swift-60f2db4fa01b
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
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
        

        self.checkAuthorizationWithHandler(completion: {_ in
            
            print("Created Album Successfully")
        })
        
        
        let concurrentQueue = DispatchQueue(label: "swiftlee.concurrent.queue", attributes: .concurrent)

        
        //let storage = Storage.storage()
        //let pathReference = storage.reference(withPath: video.storage)
        
        //https://www.avanderlee.com/swift/concurrent-serial-dispatchqueue/
        //https://stackoverflow.com/questions/24056205/how-to-use-background-thread-in-swift
        
        registerBackgroundTask()
        DispatchQueue.global(qos: .background).async{
            var url = self.video.downloadURL

        //pathReference.downloadURL{ url, error in
            var vid = AVAsset(url: url!)
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-DD"
            
            
            print(vid.creationDate)

            
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
                        DispatchQueue.global(qos: .background).async{
                            if let data = data{
                                if let _ = try? data.write(to: destinationURL, options: Data.WritingOptions.atomic){
                                    print(destinationURL)
                                    print("Converting format")
                                    let preset = AVAssetExportPresetHighestQuality
                                    let outFileType = AVFileType.mov
                                    
                                    
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
                                        DispatchQueue.global(qos: .background).async {
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
            

        }
        
        }
        
       
        

}

