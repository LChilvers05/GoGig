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
    
    @IBOutlet weak var emailField: MyTextField!
    @IBOutlet weak var passwordField: MyTextField!
    @IBOutlet weak var confirmPasswordField: MyTextField!
    @IBOutlet weak var topLSButton: UIButton!
    @IBOutlet weak var bottomLSButton: UIButton!
    @IBOutlet weak var switchPrompt: UILabel!
    
    var userData: Dictionary<String, Any>?
    
    var email: String?
    var password: String?
    
    var logInMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        emailField.updateCharacterLimit(limit: 62)
        passwordField.updateCharacterLimit(limit: 30)
        confirmPasswordField.updateCharacterLimit(limit: 30)
        
        logInMode = false
        //Initially will be Log In
        logInMode = switchMode(logInMode: logInMode)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func switchMode(logInMode: Bool) -> Bool{
        
        //Hide everything for Sign up
        if logInMode == false {
            
            emailField.text = ""
            passwordField.text = ""
            passwordField.placeholder = "password"
            confirmPasswordField.text = ""
            
            confirmPasswordField.isHidden = true
            
            topLSButton.setImage(UIImage(named: "loginButton"), for: .normal)
            bottomLSButton.setImage(UIImage(named: "signupButton"), for: .normal)
            
            switchPrompt.text = "New to GoGig? Create an account"
            
            return true
            
            
        //Show everything for Sign up
        } else {
            
            emailField.text = ""
            passwordField.text = ""
            passwordField.placeholder = "create password"
            confirmPasswordField.text = ""
            
            confirmPasswordField.isHidden = false
            
            topLSButton.setImage(UIImage(named: "signupButton"), for: .normal)
            bottomLSButton.setImage(UIImage(named: "loginButton"), for: .normal)
            
            switchPrompt.text = "Already have an account?"
            
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
                        
                        
                        //user is signing up
                        if logInMode == false {
                            //password security checks
                            if userPassword.count > 6 {
                                if let confirmUserPassword = confirmPasswordField.text {
                                    if confirmUserPassword != "" && confirmUserPassword == userPassword {
                                        
                                        userData = ["email": userEmail, "bio": "", "gigs": true, "name": "", "picURL": "", "website": "", "phone": "", "instagram": "", "twitter": "", "facebook": "", "appleMusic": "", "spotify": ""]
                                        
                                        self.performSegue(withIdentifier: TO_CREATE_PROFILE, sender: nil)
                                        
                                    } else {
                                        displayError(title: "Passwords", message: "The password confirmation does not match")
                                    }
                                }
                            } else {
                                displayError(title: "Password Length", message: "Choose a good, strong password more than 6 characters")
                            }
                            
                        
                        //user is logging in
                        } else {
                            
                            AuthService.instance.loginUser(withEmail: userEmail, andPassword: userPassword, loginComplete: {(user, error) in
                                if error != nil {
                                    
                                    self.displayError(title: "Couldn't Log In", message: error!.localizedDescription)
                                    
                                } else {
                                    
                                    //Dismiss the LoginVC showing UserAccountVC
                                    self.dismiss(animated: true, completion: nil)
                                    
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
        logInMode = switchMode(logInMode: logInMode)
    }
    
    //So prepare for CreateProfileCAVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_CREATE_PROFILE {
            
            //Need this line to pass information between view controllers
            let createProfileCAVC = segue.destination as! CreateProfileCAVC
            
            //Changes it
            createProfileCAVC.userData = self.userData
            createProfileCAVC.email = emailField.text
            createProfileCAVC.password = passwordField.text
        }
    }
}
