//
//  InfoContactCGVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/06/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class InfoContactCGVC: UIViewController {
    
    @IBOutlet weak var descriptionTextView: MyTextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var user: User?
    var eventData: Dictionary<String, Any>?
    
    var placeholder = """
Write a description...
Things to think about:
•The style of music wanted
•How big the event will be
•The length of their performance
•Any equipment you cannot supply
"""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup placeholder of the description text view
        descriptionTextView.updatePlaceholder(placeholder: placeholder)
        descriptionTextView.text = placeholder
        descriptionTextView.textColor = UIColor.lightGray
        
        //Auto-filled
        nameTextField.text = user?.name
        emailTextField.text = user?.email
        //Add later on
        //phoneTextField.text = user?.phone
        
        hideKeyboard()
    }
    override func viewDidAppear(_ animated: Bool) {
        print(eventData!)
    }
    
    func checkPhoneField() {
        //Less checks needed as number pad keyboard is used
        if let phone = phoneTextField.text {
            if phone.count > 7 {
                
                eventData!["phone"] = phone
            }
        }
    }
    
    
    @IBAction func continueButton(_ sender: Any) {
        if let description = descriptionTextView.text {
            if let name = nameTextField.text {
                if let email = emailTextField.text {
                    if let phone = phoneTextField.text {
                        if name != "" && name.count <= 100 {
                            if description.count > 10 && !(description.contains("Write a description... |")) {
                                
                                eventData!["name"] = name
                                eventData!["description"] = description
                                
                                //add email...
                                if email.contains("@") && email.contains(".") && email.count >= 5 && email.count <= 62 {
                                    
                                    eventData!["email"] = email
                                    
                                    //...and phone
                                    checkPhoneField()
                                    
                                    performSegue(withIdentifier: TO_ADD_PHOTO, sender: nil)
                                    
                                    //Just Add Phone
                                } else if phone.count >= 7 {
                                    
                                    eventData!["phone"] = phone
                                    
                                    performSegue(withIdentifier: TO_ADD_PHOTO, sender: nil)
                                    
                                } else {
                                    
                                    displayError(title: "Contact Information", message: "please enter a valid email address or phone number")
                                }
                                
                            } else {
                                displayError(title: "Event Description", message: "please enter a description of your event outlining the suggested points")
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_ADD_PHOTO {
            
            let photoCGVC = segue.destination as! PhotoCGVC
            
            photoCGVC.user = user
            photoCGVC.eventData = eventData
            
        }
    }
}

