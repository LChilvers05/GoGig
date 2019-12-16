//
//  LoginSignupVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 29/08/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstanceID

class LoginSignupVC: UIViewController {
    
    @IBOutlet weak var fieldsStack: UIStackView!
    @IBOutlet weak var emailField: MyTextField!
    @IBOutlet weak var passwordField: MyTextField!
    @IBOutlet weak var confirmPasswordField: MyTextField!
    @IBOutlet weak var topLSButton: UIButton!
    @IBOutlet weak var bottomLSButton: UIButton!
    @IBOutlet weak var switchPrompt: UILabel!
    
    var userData: Dictionary<String, Any>?
    
    var email: String?
    var password: String?
    //keep track of what state view is in
    var logInMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //for iOS 13
        self.modalPresentationStyle = .overFullScreen
        setupView()
        hideKeyboard()
        emailField.updateCharacterLimit(limit: 62)
        passwordField.updateCharacterLimit(limit: 30)
        confirmPasswordField.updateCharacterLimit(limit: 30)
        
        logInMode = false
        //initially will be Log In
        logInMode = switchMode(logInMode: logInMode)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func switchMode(logInMode: Bool) -> Bool{
        
        //hide everything for Sign up
        if logInMode == false {
            
            emailField.text = ""
            passwordField.text = ""
            //change from "create password"
            passwordField.placeholder = "password"
            confirmPasswordField.text = ""
            
            confirmPasswordField.isHidden = true
            
            //change the images of the top and bottom login and signup buttons
            topLSButton.setImage(UIImage(named: "loginButton"), for: .normal)
            bottomLSButton.setImage(UIImage(named: "signupButton"), for: .normal)
            
            //change the prompt so the user knows what the bottom button does
            switchPrompt.text = "New to GoGig? Create an account"
            
            //return the new logInMode
            //logInMode = true is logging in state
            return true
            
            
        //show everything for Sign up
        } else {
            
            //reset input when changing mode
            emailField.text = ""
            passwordField.text = ""
            passwordField.placeholder = "create password"
            confirmPasswordField.text = ""
            
            //show the confirm password field
            confirmPasswordField.isHidden = false
            
            //swap the images for the buttons
            topLSButton.setImage(UIImage(named: "signupButton"), for: .normal)
            bottomLSButton.setImage(UIImage(named: "loginButton"), for: .normal)
            
            switchPrompt.text = "Already have an account?"
            
            //return logInMode as false
            return false
        }
    }
    
    @IBAction func topLSButton(_ sender: Any) {
        
        //email
        if let userEmail = emailField.text {
            if userEmail != "" && userEmail.contains("@") && userEmail.count > 3 {
                //password
                if let userPassword = passwordField.text {
                    if userPassword != "" {
                        //USER IS SIGNING UP
                        if logInMode == false {
                            //password validation checks
                            if userPassword.count > 6 {
                                if let confirmUserPassword = confirmPasswordField.text {
                                    if confirmUserPassword != "" && confirmUserPassword == userPassword {
                                        //data dictionary for Database
                                        userData = ["email": userEmail, "bio": "", "gigs": true, "name": "", "picURL": "", "website": "", "phone": "", "instagram": "", "twitter": "", "facebook": "", "appleMusic": "", "spotify": ""]
                                        
                                        self.performSegue(withIdentifier: TO_CREATE_PROFILE, sender: nil)
                                        
                                    } else {
                                        displayError(title: "Passwords", message: "The password confirmation does not match")
                                    }
                                }
                            } else {
                                displayError(title: "Password Length", message: "Choose a good, strong password more than 6 characters")
                            }
                            
                        
                        //USER IS LOGGING IN
                        } else {
                            //log the user in
                            AuthService.instance.loginUser(withEmail: userEmail, andPassword: userPassword, loginComplete: {(user, error) in
                                if error != nil {
                                    //if it goes wrong
                                    self.displayError(title: "Couldn't Log In", message: error!.localizedDescription)
                                    
                                } else {
                                    
                                    //dismiss the LoginVC showing UserAccountVC
                                    self.dismiss(animated: true, completion: nil)
                                    //call notification to refresh the tabs
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTabs"), object: nil)
                                    
                                    //update the deviceFCMToken for push notifications
                                    InstanceID.instanceID().instanceID { (result, error) in
                                        if let error = error {
                                            print("Error fetching remote instance ID: \(error)")
                                        } else if let result = result {
                                            print("Remote instance ID token: \(result.token)")
                                            deviceFCMToken = result.token
                                        }
                                    }
                                }
                            })
                        }
                        
                    } else {
                        displayError(title: "Oops", message: "Please enter a password")
                    }
                }
            } else {
                displayError(title: "Oops", message: "Please enter a valid email address")
            }
        }
    }
    
    @IBAction func bottomLSButton(_ sender: Any) {
        //when bottom button pressed, the returned Bool value is the new state of view
        logInMode = switchMode(logInMode: logInMode)
    }
    
    //prepare for CreateProfileCAVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_CREATE_PROFILE {
            
            //need this line to pass information between view controllers
            let createProfileCAVC = segue.destination as! CreateProfileCAVC
            
            //changes it
            createProfileCAVC.userData = self.userData
            createProfileCAVC.email = emailField.text
            createProfileCAVC.password = passwordField.text
        }
    }
}
