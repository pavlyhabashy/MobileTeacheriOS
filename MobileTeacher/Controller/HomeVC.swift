//
//  HomeVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/1/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HomeVC: UIViewController {

    @IBOutlet weak var watchVideosOutlet: UIButton!
    @IBOutlet weak var uploadButtonOutlet: UIButton!
    @IBOutlet weak var howToUseOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        db.collection("update").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let b:Bool = document.get("updateAvailable") as! Bool
                    if b{
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Update Availiable", message: "Please visit the app store to update the app.", preferredStyle: .alert)

                            alert.addAction(UIAlertAction(title: "Thanks", style: .default, handler: nil))

                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }

        // Do any additional setup after loading the view.
        watchVideosOutlet.layer.cornerRadius = 15
//        watchVideosOutlet.setBackgroundColor(color: UIColor.white, forState: UIControl.State.highlighted)
        
        uploadButtonOutlet.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        uploadButtonOutlet.layer.borderWidth = 2.0
        uploadButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
//        uploadButtonOutlet.layer.borderColor = #colorLiteral(red: 0.3277398944, green: 0.5051055551, blue: 0.190628171, alpha: 1)
        uploadButtonOutlet.layer.cornerRadius = 15
        
        howToUseOutlet.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        howToUseOutlet.layer.borderWidth = 2.0
        howToUseOutlet.layer.borderColor = UIColor.systemBlue.cgColor
//        howToUseOutlet.layer.borderColor = #colorLiteral(red: 0.3277398944, green: 0.5051055551, blue: 0.190628171, alpha: 1)
        howToUseOutlet.layer.cornerRadius = 15
        
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
           return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
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

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
