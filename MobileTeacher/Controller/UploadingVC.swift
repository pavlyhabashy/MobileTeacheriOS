//
//  UploadingVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 11/23/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVKit


class UploadingVC: UIViewController {

    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    var uuid:String!
    let shapeLayer = CAShapeLayer()
    
    let percentLabel: UILabel = {
       let label = UILabel()
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    var uploadTask:StorageUploadTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        cancelButtonOutlet.layer.cornerRadius = 15
        
        view.addSubview(percentLabel)
        percentLabel.frame = CGRect(x:0, y:0, width:100, height:100)
        percentLabel.center = view.center
        
        //print("asdf")
        print(uploadTask)
        super.viewDidLoad()

        //let shapeLayer = CAShapeLayer()
        
        let center = view.center
        
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
        
        
        uploadTask.observe(.success){snapshot in
           print("UUID")
            print(self.uuid!)
           
            //sleep(1) //https://firebase.google.com/docs/storage/ios/download-files
            let vidRef = Storage.storage().reference().child("\(self.uuid!).mov")
           
            vidRef.downloadURL{url, error in
                if error != nil{
                    print(error)
                    return
                }else{
                    
                    let asset = AVAsset(url: url as! URL)
                           
                           print("Duration of Video from Firebase:\(CMTimeGetSeconds(asset.duration))")
                    
                    //print("URL")
                    //print(url)
                    
                    //let player = AVPlayer(url: url!)
                    
                    //let playerViewController = AVPlayerViewController()
                    //playerViewController.player = player
                    
                    //self.present(playerViewController, animated: true){
                      //  player.play()
                    //}//https://www.raywenderlich.com/5191-video-streaming-tutorial-for-ios-getting-started
                }
            
            }
            print(vidRef)
            
            //https://stackoverflow.com/questions/26347777/swift-how-to-remove-optional-string-character
            
        }
        //https://www.youtube.com/watch?v=ZaW-xPmjutA&t=845s
        uploadTask.observe(.progress){snapshot in
                   let percentComplete =  CGFloat(snapshot.progress!.completedUnitCount) / CGFloat(snapshot.progress!.totalUnitCount)
                   
                   
                
                self.shapeLayer.strokeEnd = percentComplete
            
                var percentage = String(format:"%.f", percentComplete*100)
            
                print(percentage)
                self.percentLabel.text = "\(percentage)%"
        }
        
        uploadTask.observe(.pause){ snapshot in
            
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

    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        uploadTask.cancel()
    }
}
