//
//  UploadVideoTVC.swift
//  MobileTeacher
//
//  Created by Pavly Habashy on 10/2/19.
//  Copyright © 2019 Pavly Habashy. All rights reserved.
//

import UIKit
import Eureka

class VideoFormVC: FormViewController, UIAdaptivePresentationControllerDelegate {
    
    var languages = [
        "Mandarin Chinese",
        "Spanish",
        "English",
        "Hindi/Urdu",
        "Arabic",
        "Bengali",
        "Portuguese",
        "Russian",
        "Japanese",
        "German",
        "Javanese",
        "Punjabi",
        "Wu",
        "French",
        "Telugu",
        "Vietnamese",
        "Marathi",
        "Korean",
        "Tamil",
        "Italian",
        "Turkish",
        "Cantonese/Yue"    ]
    
    var countries = ["Select a country","Afghanistan","Albania","Algeria","Andorra","Angola","Anguilla","Antigua & Barbuda","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia","Bosnia & Herzegovina","Botswana","Brazil","British Virgin Islands","Brunei","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Cape Verde","Cayman Islands","Chad","Chile","China","Colombia","Congo","Cook Islands","Costa Rica","Cote D Ivoire","Croatia","Cruise Ship","Cuba","Cyprus","Czech Republic","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Estonia","Ethiopia","Falkland Islands","Faroe Islands","Fiji","Finland","France","French Polynesia","French West Indies","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guam","Guatemala","Guernsey","Guinea","Guinea Bissau","Guyana","Haiti","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kuwait","Kyrgyz Republic","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macau","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Namibia","Nepal","Netherlands","Netherlands Antilles","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Puerto Rico","Qatar","Reunion","Romania","Russia","Rwanda","Saint Pierre & Miquelon","Samoa","San Marino","Satellite","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","South Africa","South Korea","Spain","Sri Lanka","St Kitts & Nevis","St Lucia","St Vincent","St. Lucia","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Timor L'Este","Togo","Tonga","Trinidad & Tobago","Tunisia","Turkey","Turkmenistan","Turks & Caicos","Uganda","Ukraine","United Arab Emirates","United Kingdom", "United States of America", "Uruguay","Uzbekistan","Venezuela","Vietnam","Virgin Islands (US)","Yemen","Zambia","Zimbabwe"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languages.sort()
        languages.insert("Select a language", at: 0)
        languages.append("Other")
        countries.append("Other")
                
        animateScroll = true
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        
        form +++ Section(header: "Name", footer: "If you work with a U.S. Peace Corps Volunteer (PCV) or English Language Fellow (ELF), please enter their name also.")
            <<< NameRow("Name"){ row in
                row.title = "Teacher's Name"
                row.placeholder = "Enter name here"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellUpdate{ (cell, row) in
                
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
                if cell.textField.isEditing {
                    cell.textLabel?.textColor = .systemBlue
                    if #available(iOS 13.0, *) {
                        cell.textField.textColor = .label
                    } else {
                        // Fallback on earlier versions
                        cell.textField.textColor = .black
                    }
                } else {
                    if cell.textField.text == "" {
                        cell.textField.textColor = .lightGray
                    } else {
                        if #available(iOS 13.0, *) {
                            cell.textField.textColor = .label
                        } else {
                            // Fallback on earlier versions
                            cell.textField.textColor = .black
                        }
                    }
                }
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                }
            }
            
            
            
            +++ Section(header: "Email", footer: "")
            <<< EmailRow("Email") { row in
                row.title = "Teacher's Email"
                row.placeholder = "Enter email here"
                row.add(rule: RuleRequired())
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChangeAfterBlurred
            }.cellUpdate{ (cell, row) in
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
                if cell.textField.isEditing {
                    cell.textLabel?.textColor = .systemBlue
                    if #available(iOS 13.0, *) {
                        cell.textField.textColor = .label
                    } else {
                        // Fallback on earlier versions
                        cell.textField.textColor = .black
                    }
                } else {
                    if cell.textField.text == "" {
                        cell.textField.textColor = .lightGray
                    } else {
                        if #available(iOS 13.0, *) {
                            cell.textField.textColor = .label
                        } else {
                            // Fallback on earlier versions
                            cell.textField.textColor = .black
                        }
                    }
                }
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                }
            }
        
        form +++ Section(header: "Video Name", footer: "")
            <<< NameRow("Video Name"){ row in
                row.title = "Video Name"
                row.placeholder = "Enter video name here"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellUpdate{ (cell, row) in
                
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
                if cell.textField.isEditing {
                    cell.textLabel?.textColor = .systemBlue
                    if #available(iOS 13.0, *) {
                        cell.textField.textColor = .label
                    } else {
                        // Fallback on earlier versions
                        cell.textField.textColor = .black
                    }
                } else {
                    if cell.textField.text == "" {
                        cell.textField.textColor = .lightGray
                    } else {
                        if #available(iOS 13.0, *) {
                            cell.textField.textColor = .label
                        } else {
                            // Fallback on earlier versions
                            cell.textField.textColor = .black
                        }
                    }
                }
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                }
            }
        
        form +++ Section(header: "Video Description", footer: "")
            <<< TextAreaRow("Video Description"){ row in
                row.title = "Video Description"
                row.placeholder = "Enter video description here"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }.cellUpdate{ (cell, row) in
                
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
                if /*cell.textField.isEditing*/cell.textView.isEditable {
                    cell.textLabel?.textColor = .systemBlue
                    if #available(iOS 13.0, *) {
                        cell.textView.textColor = .label
                    } else {
                        // Fallback on earlier versions
                        cell.textView.textColor = .black
                    }
                } else {
                    if cell.textView.text == "" {
                        cell.textView.textColor = .lightGray
                    } else {
                        if #available(iOS 13.0, *) {
                            cell.textView.textColor = .label
                        } else {
                            // Fallback on earlier versions
                            cell.textView.textColor = .black
                        }
                    }
                }
                if !row.isValid {
                    cell.textView.textColor = .systemRed
                }
            } //https://developer.apple.com/documentation/uikit/uitextview
        
        form +++ SelectableSection<ListCheckRow<String>>(header: "Subject", footer: "What subject does the teacher teach in the video?", selectionType: .singleSelection(enableDeselection: true))
        
        let subjects = ["Languages", "Math", "Science", "History", "Art", "Music", "Health", "Other"]
        for option in subjects {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                listRow.value = nil
            }.cellUpdate{ (cell, row) in
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
            }
            
//            if (option == "Other") {
//                form.last! <<< TextRow("Other Subject") {
//                    $0.hidden = Condition.function(["Other"], { form in
//                        if (form.rowBy(tag: "Other") as? ListCheckRow)?.value == "Other" {
//                            return false
//                        }
//                        return true
//                    })
//                    $0.placeholder = "Enter other subject"
//                }.cellUpdate{ (cell, row) in
//                    if #available(iOS 13.0, *) {
//                        cell.textLabel?.textColor = .label
//                    } else {
//                        // Fallback on earlier versions
//                        cell.textLabel?.textColor = .black
//                    }
//                    if cell.textField.isEditing {
//                        cell.textLabel?.textColor = .systemBlue
//                        if #available(iOS 13.0, *) {
//                            cell.textField.textColor = .label
//                        } else {
//                            // Fallback on earlier versions
//                            cell.textField.textColor = .black
//                        }
//                    } else {
//                        if cell.textField.text == "" {
//                            cell.textField.textColor = .lightGray
//                        } else {
//                            if #available(iOS 13.0, *) {
//                                cell.textField.textColor = .label
//                            } else {
//                                // Fallback on earlier versions
//                                cell.textField.textColor = .black
//                            }
//                        }
//                    }
//                }
//            }
        }
        
        form +++ SelectableSection<ListCheckRow<String>>(header: "Level of Students", footer: "Check all that apply.", selectionType: .multipleSelection)
        
        let levels = ["Beginner", "Intermediate", "Advanced"]
        for option in levels {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                listRow.value = nil
            }.cellUpdate{ (cell, row) in
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
            }
        }
        form +++ Section(header: "Country/Region/Territory", footer: "Where is the teacher in the video?")
            <<< PickerInputRow<String>("Country"){
//                $0.title = "Country/Region/Territory"
                $0.options = countries
                $0.value = $0.options.first
            }.cellUpdate{ (cell, row) in
                if #available(iOS 13.0, *) {
                    cell.textLabel?.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textLabel?.textColor = .black
                }
                if cell.isSelected {
                    cell.textLabel?.textColor = .systemBlue
                }
            }
        
        
        form +++ Section(header: "Language", footer: "What language does the teacher speak in the video?")
        <<< PickerInputRow<String>("Language"){
            $0.options = languages
            $0.value = $0.options.first
        }.cellUpdate{ (cell, row) in
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = .label
            } else {
                // Fallback on earlier versions
                cell.textLabel?.textColor = .black
            }
            if cell.isSelected {
                cell.textLabel?.textColor = .systemBlue
            }
        }
        
        +++ Section(header: "School/University", footer: "What is the name of the school or university where the teacher works?")
        <<< TextRow("School") { row in
            row.title = "Name of Institution"
            row.placeholder = "Enter name here"
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
        }.cellUpdate{ (cell, row) in
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = .label
            } else {
                // Fallback on earlier versions
                cell.textLabel?.textColor = .black
            }
            if cell.textField.isEditing {
                cell.textLabel?.textColor = .systemBlue
                if #available(iOS 13.0, *) {
                    cell.textField.textColor = .label
                } else {
                    // Fallback on earlier versions
                    cell.textField.textColor = .black
                }
            } else {
                if cell.textField.text == "" {
                    cell.textField.textColor = .lightGray
                } else {
                    if #available(iOS 13.0, *) {
                        cell.textField.textColor = .label
                    } else {
                        // Fallback on earlier versions
                        cell.textField.textColor = .black
                    }
                }
            }
            
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        form +++ Section(header: "", footer: "")
            <<< ButtonRow(){
                $0.title = "Next"
                
                $0.onCellSelection { (string, buttonrow) in
                    let valuesDictionary = self.form.values()
                    self.formValidate(dict: valuesDictionary as Dictionary<String, Any>)
                    print(valuesDictionary)
                }
        }
        
        
        
    }
    
    func formValidate(dict: Dictionary<String, Any>) {
        
        // Check for name
        if let name = dict["Name"] as? String {
            print(name)
        } else {
            missingFieldAlert(error: "Teacher's Name")
            return
        }
        
        // Check for email
        if let email = dict["Email"] as? String {
            if !isValidEmail(emailStr: email) {
                let alert = UIAlertController(title: "'\(email)' is an invalid email", message: "Please enter a valid email.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            print(email)
        } else {
            missingFieldAlert(error: "Teacher's Email")
            return
        }
        
        if let videoName = dict["Video Name"] as? String {
            print(videoName)
        } else {
            missingFieldAlert(error: "Video Name")
            return
        }
        
        if let videoDescription = dict["Video Description"] as? String {
            print(videoDescription)
        } else {
            missingFieldAlert(error: "Video Description")
            return
        }

        // Check for subject
        if let subject = dict["Languages"] as? String {
            print(subject)
        } else if let subject = dict["Math"] as? String {
            print(subject)
        } else if let subject = dict["Science"] as? String {
            print(subject)
        } else if let subject = dict["History"] as? String {
            print(subject)
        } else if let subject = dict["Art"] as? String {
            print(subject)
        } else if let subject = dict["Music"] as? String {
            print(subject)
        } else if let subject = dict["Health"] as? String {
            print(subject)
        } else if let subject = dict["Other"] as? String {
            print(subject)
        } else {
            missingFieldAlert(error: "Subject")
            return
        }
        
        var levels = [String]()
        
        if let level = dict["Beginner"] as? String {
            print(level)
            levels.append(level)
        }
        if let level = dict["Intermediate"] as? String {
            print(level)
            levels.append(level)
        }
        if let level = dict["Advanced"] as? String {
            print(level)
            levels.append(level)
        }
        if levels.isEmpty {
            missingFieldAlert(error: "Level of Students")
            return
        }
        
        print(levels)
        
        if let country = dict["Country"] as? String {
            if country == "Select a country" {
                missingFieldAlert(error: "Country/Region/Territory")
                return
            }
            print(country)
        }
        
        if let language = dict["Language"] as?  String {
            if language == "Select a language" {
                missingFieldAlert(error: "Language")
                return
            }
            print(language)
        }
        
        if let school = dict["School"] as?  String {
            print(school)
        } else {
            missingFieldAlert(error: "School/University")
            return
        }
        
        performSegue(withIdentifier: "uploadVideoSegue", sender: dict)
        
    }
    
    func missingFieldAlert(error: String) {
        let alert = UIAlertController(title: "'\(error)' field is empty", message: "Please complete the missing field.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
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
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "Are you sure you want to discard this form?", message: "You have entered information in this form. If you discard the form, your information will be deleted. Are you sure you want to discard the form anyway?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {
            alert in
            self.navigationController?.dismiss(animated: true, completion: {
            })
        }))
        self.present(alert, animated: true)
    }
    
    
    //https://medium.com/infancyit/traveling-through-the-app-the-segue-magic-part-1-a8091e863164
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.destination is VideoUploadVC{
            let vc = segue.destination as? VideoUploadVC
            vc?.dict = sender as! Dictionary<String, Any>
            
        }
    }
    
    
}
