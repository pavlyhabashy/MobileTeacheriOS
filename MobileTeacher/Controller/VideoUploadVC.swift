//
//  UploadVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 11/20/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation

class VideoUploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let vidSelectorController = UIImagePickerController()
    
    var dict: Dictionary<String, Any>!
    var uuid:String!
    var url:NSURL!
    var uploadTask:StorageUploadTask!
    var length:Int!
    
    // Outlets
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var chooseVideoButtonOutlet: UIButton!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var thumbnailContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("UploadVideo")
        print(dict)
        vidSelectorController.delegate = self
        
        chooseVideoButtonOutlet.layer.cornerRadius = 15
        
        uploadButtonOutlet.layer.cornerRadius = 15
        uploadButtonOutlet.isEnabled = false
        uploadButtonOutlet.backgroundColor = .systemGray
        
        // Set corner radius
        let cornerRadius : CGFloat = 25.0
        
        thumbnailContainerView.layer.cornerRadius = cornerRadius
        thumbnailContainerView.layer.shadowColor = UIColor.systemGray.cgColor
        thumbnailContainerView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        thumbnailContainerView.layer.shadowRadius = 10
        thumbnailContainerView.layer.shadowOpacity = 0.2
        thumbnailContainerView.layer.shadowPath = UIBezierPath(roundedRect: videoThumbnail.bounds, cornerRadius: cornerRadius).cgPath
        videoThumbnail.layer.cornerRadius = cornerRadius
        videoThumbnail.clipsToBounds = true
    }
    
    
    @IBOutlet weak var uploadButton: UIButton!
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is UploadingVC {
            let vc = segue.destination as? UploadingVC
            vc?.uploadTask = self.uploadTask
            vc?.uuid = self.uuid
            vc?.dict = self.dict
            vc?.length = self.length
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to discard this form?", message: "You have entered information in this form. If you discard the form, your information will be deleted. Are you sure you want to discard the form anyway?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {
            alert in
            self.navigationController?.dismiss(animated: true, completion: {
            })
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func chooseVideoPressed(_ sender: Any) {
        // Willie Shen
        
        vidSelectorController.mediaTypes = ["public.movie"]
        vidSelectorController.allowsEditing = true
        
        //http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/
        present(vidSelectorController, animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("Here")
        let video = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        
        url = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        
        print(url!)
        
        //https://developer.apple.com/documentation/uikit/uiimageview
        //https://stackoverflow.com/questions/44267013/get-the-accurate-duration-of-a-video
        
        do {
            let asset = AVAsset(url: url as URL)
            let imgGenerator = AVAssetImageGenerator(asset:asset)
            
            imgGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0,timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            videoThumbnail.image = thumbnail
            print("Duration:\(CMTimeGetSeconds(asset.duration))")
            length = Int(CMTimeGetSeconds(asset.duration))
            //https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html
            print(length!)
        } catch let error {
            print(error)
            return
        }
        //https://github.com/davidseek/Thumbnail-From-Video-Swift
        //https://medium.com/@PaulWall43/generating-video-thumnails-at-runtime-in-ios-swift-a2b092301c9a
        
        
        
        
        
        dismiss(animated: true, completion:nil)
        //http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/
        uploadButtonOutlet.backgroundColor = .systemBlue
        uploadButtonOutlet.isEnabled = true
        uploadButtonOutlet.shake()
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        
        if(url==nil){
            let alert = UIAlertController(title: "Error: No Video Selected", message: "Please select a video to upload.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference()
        
        uuid = UUID().uuidString
        
        
        //https://www.hackingwithswift.com/articles/178/super-powered-string-interpolation-in-swift-5-0
        let videoRef = storageRef.child("\(uuid!).mov")
        
        //let filePath = (url?.absoluteString)!
        
        //let uploadTask = videoRef.putFile(from: url! as URL)
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        //https://stackoverflow.com/questions/58104572/cant-upload-video-to-firebase-storage-on-ios-13
        let videoData = NSData(contentsOf: (url?.absoluteURL)!) as Data?
        
        uploadTask = videoRef.putData(videoData!, metadata: metadata)
        //print(uploadTask)
        performSegue(withIdentifier: "uploadingSegue", sender: self)
        
    }
    
    
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
