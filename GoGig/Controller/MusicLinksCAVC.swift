//
//  MusicLinksCAVC.swift
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

class MusicLinksCAVC: UIViewController {

    @IBOutlet weak var fieldsStack: UIStackView!
    @IBOutlet weak var appleMusicField: MyTextField!
    @IBOutlet weak var spotifyField: MyTextField!
    let loadingSpinner = SpinnerViewController()
    
    var user: User?
    
    var userData: Dictionary<String, Any>?
    
    var email: String?
    var password: String?
    
    var userGigs: Bool?
    
    var imageID = ""
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideKeyboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    //auto-fill if editing
    override func viewDidAppear(_ animated: Bool) {
        if editingProfile == true && user != nil {
            appleMusicField.text = user?.getAppleMusic()
            spotifyField.text = user?.getSpotify()
        }
    }
    
    
    //MARK: STAGE 6: UPLOAD PROFILE PICTURE (If musician)
    
    //put the profile pic in firebase storage
    func picUpload(uid: String, handler: @escaping (_ url: URL) -> ()) {
        
        if let userPic = profileImage {
            
            DataService.instance.updateSTPic(uid: uid, directory: "profilePic", imageContent: userPic, imageID: imageID, uploadComplete: { (success, error) in
                if error != nil {
                    self.removeSpinnerView(self.loadingSpinner)
                    self.displayError(title: "There was an Error", message: error!.localizedDescription)
                    
                } else {
                    
                    DataService.instance.getSTURL(uid: uid, directory: "profilePic", imageID: self.imageID) { (returnedURL) in
                        
                        handler(returnedURL)
                        
                    }
                }
            })
        }
    }
    
    @IBAction func continueButton(_ sender: Any) {
        //check streaming links
        var continueFine = true
        if let userAppleMusic = appleMusicField.text {
            if (userAppleMusic.contains(".") && userAppleMusic.count > 5) || userAppleMusic == "" {
                userData!["appleMusic"] = userAppleMusic
            } else {
                displayError(title: "Oops", message: "Please enter a valid Apple Music URL (optional)")
                continueFine = false
            }
        }
        if let userSpotify = spotifyField.text {
            if (userSpotify.contains(".") && userSpotify.count > 5) || userSpotify == "" {
                userData!["spotify"] = userSpotify
            } else {
                displayError(title: "Oops", message: "Please enter a valid Spotify URL (optional)")
                continueFine = false
            }
        }
        
        //do same as we did for organiser
        if continueFine {
            
            createSpinnerView(self.loadingSpinner)
            if editingProfile == false {
                //sign the user up
                AuthService.instance.registerUser(withEmail: email!, andPassword: password!, userCreationComplete: { (success, error) in
                    if error != nil {
                        
                        self.removeSpinnerView(self.loadingSpinner)
                        self.displayError(title: "There was an Error", message: error!.localizedDescription)
                        
                    } else {
                        
                        //successfuly registered and added to database
                        //now log user in
                        AuthService.instance.loginUser(withEmail: self.email!, andPassword: self.password!, loginComplete: { (success, nil) in })
                        
                        self.updateUserData()
                    }
                })
            } else {
                //user is editing their profile
                self.updateUserData()
            }
        }
    }
    
    func updateUserData(){
        if let uid = Auth.auth().currentUser?.uid {
            //upload the pic to cloud storage
            self.picUpload(uid: uid) { (returnedURL) in
                
                self.userData!["picURL"] = returnedURL.absoluteString
                
                DataService.instance.updateDBUserProfile(uid: uid, userData: self.userData!) { (complete) in
                    
                    if complete {
                        
                        accountGateOpen = true
                        
                        self.removeSpinnerView(self.loadingSpinner)
                        
                        //now do a dismiss rather than a perform segue, this is because when performing a segue, we instantiate a new tab controller
                        if !editingProfile {
                            //creating account
                            self.performSegue(withIdentifier: TO_MAIN_2, sender: nil)
                        } else {
                            //dismiss for editing
                            self.dismiss(animated: true)
                            editingProfile = false
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTabs"), object: nil)
                        }
                        //update FCM Token for push notifications
                        InstanceID.instanceID().instanceID { (result, error) in
                            if let error = error {
                                print("Error fetching remote instance ID: \(error)")
                            } else if let result = result {
                                print("Remote instance ID token: \(result.token)")
                                deviceFCMToken = result.token
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        if segue.identifier == TO_MAIN_2 {
            
            let tabBarController = segue.destination as! TabBarController
            tabBarController.userGigs = self.userGigs
            editingProfile = false
            
        }
    }
}
