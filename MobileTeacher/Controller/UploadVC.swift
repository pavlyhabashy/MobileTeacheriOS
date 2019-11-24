//
//  UploadVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 11/20/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

class UploadVC: UIViewController {

    @IBOutlet weak var chooseVideoButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        chooseVideoButtonOutlet.layer.cornerRadius = 15
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
    }
    
}
