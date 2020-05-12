//
//  UploadingVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 11/23/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseStorage
//import AVKit
import FirebaseCore
import FirebaseFirestore


class UploadingVC: UIViewController {
    
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    var uuid:String!
    let shapeLayer = CAShapeLayer()
    var dict: Dictionary<String, Any>!
    var db:Firestore!
    var length:Int!
    
    let percentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    var uploadTask: StorageUploadTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        cancelButtonOutlet.layer.cornerRadius = 15
        
        db = Firestore.firestore()
        //https://github.com/firebase/snippets-ios/blob/279f77d7842595a1c5ecc699e45b6de6c97b905e/firestore/swift/firestore-smoketest/ViewController.swift#L156-L168
        
        
        setupLoadingIndicator()
        startUpload()
    }
    
    func startUpload() {
        var downloadURL:URL!
        uploadTask.observe(.success){snapshot in
            print("UUID")
            print(self.uuid!)
            
            //sleep(1) //https://firebase.google.com/docs/storage/ios/download-files
                        let vidRef = Storage.storage().reference().child("\(self.uuid!).mov")
            //
                        vidRef.downloadURL{url, error in
                            if error != nil{
            //                    print(error!)
                                return
                            }else{
                                downloadURL = url
                                
                                //get the subject
                                var sub:String!
                                
                                if let subject = self.dict["Languages"] as? String {
                                    sub = subject
                                } else if let subject = self.dict["Math"] as? String {
                                    sub = subject
                                } else if let subject = self.dict["Science"] as? String {
                                    sub = subject
                                } else if let subject = self.dict["History"] as? String {
                                    sub = subject
                                } else if let subject = self.dict["Art"] as? String {
                                    sub = subject
                                } else if let subject = self.dict["Music"] as? String {
                                    sub = subject
                                } else if let subject = self.dict["Health"] as? String {
                                   sub = subject
                                } else if let subject = self.dict["Other"] as? String {
                                    sub = subject
                                }
                                
                                
                                //get the levels
                                var levels = [String]()
                                
                                if let level = self.dict["Beginner"] as? String {
                                    //print(level)
                                    levels.append(level)
                                }
                                if let level = self.dict["Intermediate"] as? String {
                                    //print(level)
                                    levels.append(level)
                                }
                                if let level = self.dict["Advanced"] as? String {
                                    //print(level)
                                    levels.append(level)
                                }
                                
                                self.db.collection("test").addDocument(data:[
                                    "country": self.dict["Country"] as! String,
                                    "language": self.dict["Language"] as! String,
                                    "school": self.dict["School"] as! String,
                                    "url": downloadURL!.absoluteString,
                                    "subject": sub!,
                                    "level": levels,
                                    "length": self.length,
                                    "title": self.dict["Video Name"],
                                    "description": self.dict["Video Description"]
                                    
                                ])
            //
            //                    let asset = AVAsset(url: url!)
            //
            //                    print("Duration of Video from Firebase:\(CMTimeGetSeconds(asset.duration))")
            //
            //                    //print("URL")
            //                    //print(url)
            //
            //                    //let player = AVPlayer(url: url!)
            //
            //                    //let playerViewController = AVPlayerViewController()
            //                    //playerViewController.player = player
            //
            //                    //self.present(playerViewController, animated: true){
            //                    //  player.play()
                                }//https://www.raywenderlich.com/5191-video-streaming-tutorial-for-ios-getting-started
                            }
            //
                        }
            //            print(vidRef)
            
            //https://stackoverflow.com/questions/26347777/swift-how-to-remove-optional-string-character
            
        
        //https://www.youtube.com/watch?v=ZaW-xPmjutA&t=845s
        uploadTask.observe(.progress){snapshot in
            let percentComplete =  CGFloat(snapshot.progress!.completedUnitCount) / CGFloat(snapshot.progress!.totalUnitCount)
            
            self.shapeLayer.strokeEnd = percentComplete
            
            let percentage = String(format:"%.f", percentComplete*100)
            
            if (percentage == "100") {
                self.cancelButtonOutlet.backgroundColor = .systemBlue
                self.cancelButtonOutlet.setTitle("Dismiss",for: .normal)
                self.shapeLayer.strokeColor = UIColor.green.cgColor
                
                
            }
            
            print(percentage)
            self.percentLabel.text = "\(percentage)%"
        }
        
        uploadTask.observe(.pause){ snapshot in
            
        }
    }
    
    fileprivate func setupLoadingIndicator() {
        view.addSubview(percentLabel)
        percentLabel.frame = CGRect(x:0, y:0, width:100, height:100)
        percentLabel.center = view.center
        
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter:.zero, radius:100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        trackLayer.position = view.center
        
        
        view.layer.addSublayer(trackLayer)
        
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = view.center
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        uploadTask.cancel()
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }
}
