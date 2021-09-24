//
//  LoginViewController.swift
//  GoGig
//
//  Created by Lee Chilvers on 09/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstanceID

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: LoginField!
    @IBOutlet weak var passwordField: LoginField!
    @IBOutlet weak var checkPasswordField: LoginField!
    
    @IBOutlet weak var topLSButton: UIButton!
    @IBOutlet weak var bottomLSButton: UIButton!
    
    @IBOutlet weak var switchPrompt: UILabel!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInMode = false
        
        //Initially will be Log In
        logInMode = switchMode(logInMode: logInMode)
        
        hideKeyboard()
    }
    
    var email = ""
    var password = ""
    
    var logInMode = false
    
    //MARK: Button Actions
    
    //Log in or Sign up
    @IBAction func topLS(_ sender: Any) {
        
        if emailField.text == "" || passwordField.text == "" {
            
            displayError(title: "Oops!", message: "Please enter a valid email and password")
            
        } else {
            
            //Error handling
            if let emailText = emailField.text {
                email = emailText
                if let passwordText = passwordField.text {
                    password = passwordText
                    
                    //User is signing up
                    if logInMode == false {
                        
                        if password.count < 6 {
                            
                            displayError(title: "Password Length", message: "Choose a good strong password longer than 6 characters")
                            
                        } else {
                            
                            if let passwordCheck = checkPasswordField.text{
                                
                                //So user's password is correct
                                if passwordCheck == "" || passwordCheck != password {
                                    displayError(title: "Passwords", message: "The password confirmation does not match the one you gave")
                                    
                                } else {
                                    
                                    //Prepare for segue override changes attributes of email and password in
                                    //CreateAccountVC class
                                    //self.clearForSegue(segueID: TO_CREATE_ACCOUNT)
                                    
                                }
                            }
                        }
                        
                        //User is logging in
                    } else {
                        
                        AuthService.instance.loginUser(withEmail: emailText, andPassword: passwordText, loginComplete: {(user, error) in
                            if error != nil {
                                
                                self.displayError(title: "There was an Error", message: error!.localizedDescription)
                                
                            } else {
                                
                                //Dismiss the LoginVC showing UserAccountVC
                                self.dismiss(animated: true, completion: nil)
                                
                                
                                //
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
                }
            }
        }
    }
    
    //Switch Log in <--> Sign up
    @IBAction func bottomLS(_ sender: Any) {
        
        logInMode = switchMode(logInMode: logInMode)
    }
    
    //MARK: Update UI
    
    func switchMode(logInMode: Bool) -> Bool{
        
        //Hide everything for Sign up
        if logInMode == false {
            
            emailField.text = ""
            passwordField.text = ""
            passwordField.placeholder = "password"
            checkPasswordField.text = ""
            
            checkPasswordField.isHidden = true
            orLabel.isHidden = true
            fbButton.isHidden = true
            googleButton.isHidden = true
            
            topLSButton.setImage(UIImage(named: "loginButton"), for: .normal)
            //topLSButton.setTitle("Log in", for: .normal)
            //bottomLSButton.setTitle("Sign up", for: .normal)
            bottomLSButton.setImage(UIImage(named: "signinButton"), for: .normal)
            
            switchPrompt.text = "New to GoGig? Create an account"
            
            return true
            
            
            //Show everything for Sign up
        } else {
            
            emailField.text = ""
            passwordField.text = ""
            passwordField.placeholder = "create Password"
            checkPasswordField.text = ""
            
            checkPasswordField.isHidden = false
            orLabel.isHidden = false
            fbButton.isHidden = false
            googleButton.isHidden = false
            
            topLSButton.setImage(UIImage(named: "signinButton"), for: .normal)
            bottomLSButton.setImage(UIImage(named: "loginButton"), for: .normal)
            
            switchPrompt.text = "Already have an account? Log in"
            
            return false
        }
        
    }
    
    func clearForSegue(segueID: String){
        
        self.performSegue(withIdentifier: segueID, sender: nil)
        
        self.emailField.text = ""
        self.passwordField.text = ""
        self.emailField.placeholder = "Let's Go Gig!"
        self.passwordField.placeholder = "Woo!"
        
    }
    
    //So signup in CreateAccountVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "" {
            
            //Need this line to pass information between view controllers
            let createAccountVC = segue.destination as! CreateAccountVC
            
            //Changes it
            createAccountVC.email = email
            createAccountVC.password = password
            
        }
    }
}

