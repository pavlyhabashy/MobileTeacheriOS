//
//  SearchTVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/20/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit

var selectedVideoTags = Set<String>()
var objectArray = [Objects]()

class FilterTVC: UITableViewController {
        
    var completionHandler: ((_ selectedVideos: Set<Video>) -> Void)?
    var taggedVideos = Set<Video>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        taggedVideos.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        addToFilteredVideos()
        DataManager.shared.browseTVC.updateTableView(taggedVideos: taggedVideos)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objectArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tag", for: indexPath) as! TagTVCell
        
        cell.switchCallback = { [weak self] (switchIsOn) in
            self?.setSwitchValue(switchIsOn: switchIsOn, forRowAtIndexPath:indexPath as NSIndexPath)
            Void()
        }
        
        cell.setTag(tag: objectArray[indexPath.row])

        return cell
    }
    
    private func setSwitchValue(switchIsOn: Bool, forRowAtIndexPath indexPath: NSIndexPath) {
        objectArray[indexPath.row].selected = switchIsOn
        if switchIsOn {
            selectedVideoTags.insert(objectArray[indexPath.row].tag)
        } else {
            selectedVideoTags.remove(objectArray[indexPath.row].tag)
        }
    }
    
    func addToFilteredVideos() {
        
        for tag in selectedVideoTags {
            let videosOfTag = globalTags[tag] ?? []     // Grab list of videos with this tag
            let videosOfTagSet = Set(videosOfTag)       // Convert list to set
            taggedVideos = taggedVideos.union(videosOfTagSet)   // Combine sets
        }
//        print("tagged: \(taggedVideos.count)")
    }

    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }
}
