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
        
        print(id)
        
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: video.storage)
        
        
        pathReference.downloadURL { url, error in
            if let error = error{
                print(error)
            }else{
                print(url)
                let urlData = NSData(contentsOf: url!) ?? nil
                
                let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                
                //https://www.tutorialspoint.com/how-to-download-a-video-using-a-url-and-save-it-in-an-photo-album-using-swift
                
                
                //download to camera roll
                let filePath="\(galleryPath)/\(UUID().uuidString).mp4"
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url!) //https://stackoverflow.com/questions/29482738/swift-save-video-from-nsurl-to-user-camera-roll
                    
                }){ saved, error in
                    if saved{
                        print("Saved")
                    }
                    if error != nil{
                        print(error)
                    }
                   
                }
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
        
    }
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
