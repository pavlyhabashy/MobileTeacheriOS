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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = video.title
        descriptionLabel.text = video.description
        // Do any additional setup after loading the view.
    }
    

    @IBAction func downloadClick(_ sender: Any) {
        
        //https://drive.google.com/open?id=1jlgGUrFWtDsGu8DQW5QiZGsm7v6rykB0
        print(video.downloadURL.absoluteString)
        var id = video.downloadURL.absoluteString.dropFirst("https://drive.google.com/open?id=".count)
        //https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
        
        //print(id)
        
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: video.storage)
        
        /*pathReference.getData(maxSize: 1000000000){ data, error in
            if let error = error{
                print(error)
            }else{
               let vid = AVFoundation(data)
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
            }
            
        }*/
        
        pathReference.downloadURL{ url, error in
            var vid = AVAsset(url: url!)
            print(vid)
            //print(vid.isCompatibleWithSavedPhotosAlbum)
            //print(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url!.absoluteString))
            
            
            
            
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

}
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
