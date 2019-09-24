//
//  CreateAccountVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 15/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//
//  Limit on user bio
//  Organisation of how files will be stored in the storgage folder

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstanceID

class CreateAccountVC: UIViewController {
    
    @IBOutlet weak var iGigButton: UIButton!
    @IBOutlet weak var iHireButton: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var bioContentView: UITextView!
    
    @IBOutlet weak var setUpCompleteButton: UIButton!
    
    var userData: Dictionary<String, Any>?
    
    //Entered in the LoginVC
    var email = ""
    var password = ""
    
    var imagePicker: UIImagePickerController?
    
    var userGigs: Bool?
    var imageID = ""
    
    var imageAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overFullScreen
        hideKeyboard()
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
    }
    
    //MARK: STAGE 1: TYPE OF USER
    
    func formatGigHire(buttonPicked: UIButton, otherButton: UIButton){ //Probably do programmatically?
        
        if otherButton.isEnabled {
            
            otherButton.isEnabled = false
            otherButton.isOpaque = true
            
        } else {
            
            otherButton.isEnabled = true
            otherButton.isOpaque = false
            
            userGigs = nil
        }
    }
    
    //IF USER CHANGES MIND DOESN'T COME BACK AS NIL
    @IBAction func iGig(_ sender: Any) {
        
        userGigs = true
        formatGigHire(buttonPicked: iGigButton, otherButton: iHireButton)
    }
    
    @IBAction func iHire(_ sender: Any) {
        
        userGigs = false
        formatGigHire(buttonPicked: iHireButton, otherButton: iGigButton)
    }
    
    //MARK: STAGE 2: PROFILE PICTURE
    @IBAction func imagePick(_ sender: Any) {
        
        openPhotoPopup(video: false, imagePicker: imagePicker!, title: "Profile Picture", message: "Take or choose a profile picture")
        
    }
    
    //Dismiss the imagePicker once one has been selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. Use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //Set the UIImageView to the image picked
        profilePicView.image = selectedImage
        imageAdded = true
        
        imageID = "\(NSUUID().uuidString).jpg"
        
        //Dismiss ImagePicker Controller
        dismiss(animated: true, completion: nil)
    }
    
    //Put the profile pic in firebase storage
    func picUpload(uid: String, handler: @escaping (_ url: URL) -> ()) {
        
        if let userPic = profilePicView.image {
            
            DataService.instance.updateSTPic(uid: uid, directory: "profilePic", imageContent: userPic, imageID: imageID, uploadComplete: { (success, error) in
                if error != nil {
                    
                    self.displayError(title: "There was an Error", message: error!.localizedDescription)
                    
                } else {
                    
                    DataService.instance.getSTURL(uid: uid, directory: "profilePic", imageID: self.imageID) { (returnedURL) in
                        
                        handler(returnedURL)
                        
                    }
                }
            })
        }
    }
    
    //MARK: STAGE 3: UPLOAD PROFILE
    
    @IBAction func setUpComplete(_ sender: Any) {
        
        if let userName = nameField.text {
            if let userBio = bioContentView.text {
                
                if imageAdded && userName != "" && userBio != "" && userGigs != nil {
                    
                    AuthService.instance.registerUser(withEmail: email, andPassword: password, userCreationComplete: { (success, error) in
                        if error != nil {
                            
                            self.displayError(title: "There was an Error", message: error!.localizedDescription)
                            
                        } else {
                            
                            //Successfuly registered and added to database
                            //Now log user in
                            AuthService.instance.loginUser(withEmail: self.email, andPassword: self.password, loginComplete: { (success, nil) in })
                            
                            if let uid = Auth.auth().currentUser?.uid { //Maybe clean this?
                                //Upload the pic to cloud storage
                                self.picUpload(uid: uid) { (returnedURL) in
                                    
                                    self.userData = ["email": self.email, "name": userName, "bio": userBio, "picURL": returnedURL.absoluteString, "gigs": self.userGigs!] //HERE
                                    
//                                    DataService.instance.updateDBUserProfile(uid: uid, userData: self.userData!)
//
//                                    self.performSegue(withIdentifier: TO_MAIN, sender: nil)
//
//
//                                    //
//                                    InstanceID.instanceID().instanceID { (result, error) in
//                                        if let error = error {
//                                            print("Error fetching remote instance ID: \(error)")
//                                        } else if let result = result {
//                                            print("Remote instance ID token: \(result.token)")
//                                            deviceFCMToken = result.token
//                                        }
//                                    }
                                }
                            }
                        }
                    })
                    
                } else {
                    
                    // User not entered everything
                    displayError(title: "Oops!", message: "You must provide all necessary information")
                }
            }
        }
    }
}

