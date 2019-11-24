//
//  UploadingVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 11/23/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

class UploadingVC: UIViewController {

    @IBOutlet weak var cancelButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.hidesBackButton = true
        cancelButtonOutlet.layer.cornerRadius = 15
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
    }
}
